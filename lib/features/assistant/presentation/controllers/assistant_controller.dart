import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/assistant_repository.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_thread.dart';

@immutable
class AssistantState {
  const AssistantState({
    required this.threads,
    required this.activeThreadId,
    required this.isAssistantTyping,
    this.lastError,
  });

  factory AssistantState.initial() {
    return AssistantState(
      threads: [_seedThread],
      activeThreadId: _seedThread.id,
      isAssistantTyping: false,
    );
  }

  final List<ChatThread> threads;
  final String activeThreadId;
  final bool isAssistantTyping;
  final String? lastError;

  ChatThread get activeThread =>
      threads.firstWhere((t) => t.id == activeThreadId);

  AssistantState copyWith({
    List<ChatThread>? threads,
    String? activeThreadId,
    bool? isAssistantTyping,
    Object? lastError = _sentinel,
  }) {
    return AssistantState(
      threads: threads ?? this.threads,
      activeThreadId: activeThreadId ?? this.activeThreadId,
      isAssistantTyping: isAssistantTyping ?? this.isAssistantTyping,
      lastError: identical(lastError, _sentinel)
          ? this.lastError
          : lastError as String?,
    );
  }
}

const _sentinel = Object();

class AssistantController extends StateNotifier<AssistantState> {
  AssistantController(this._repository) : super(AssistantState.initial());

  final AssistantRepository _repository;
  final _idRandom = math.Random();

  // Per-thread bookkeeping that doesn't belong in the UI-facing state.
  final Map<String, String> _backendThreadIds = {};       // local → backend uuid
  final Map<String, String> _languageByThread = {};       // local → language
  final Map<String, String> _lastCitizenText = {};        // for consent retry

  // Pseudonymous citizen id — stable per process. Production would
  // derive this from a device-anchored secret stored in Keychain.
  late final String _citizenPseudonym =
      'mobile-${DateTime.now().millisecondsSinceEpoch}';

  String _newId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_idRandom.nextInt(1 << 32)}';
  }

  // -- Thread management ----------------------------------------------------

  void selectThread(String threadId) {
    state = state.copyWith(activeThreadId: threadId);
  }

  String startNewThread() {
    final thread = ChatThread(
      id: _newId(),
      title: 'New conversation',
      messages: [_introMessage()],
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      threads: [thread, ...state.threads],
      activeThreadId: thread.id,
      lastError: null,
    );
    return thread.id;
  }

  // -- Sending -------------------------------------------------------------

  void sendCitizenMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final thread = state.activeThread;
    _lastCitizenText[thread.id] = trimmed;

    final citizenMessage = ChatMessage(
      id: _newId(),
      role: ChatRole.citizen,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text: trimmed,
    );
    final updatedThread = thread.copyWith(
      title: thread.messages.length <= 1 ? _summarise(trimmed) : thread.title,
      messages: [...thread.messages, citizenMessage],
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      threads: _replaceThread(updatedThread),
      isAssistantTyping: true,
      lastError: null,
    );

    unawaited(_dispatch(threadLocalId: thread.id, text: trimmed));
  }

  Future<void> _dispatch({
    required String threadLocalId,
    required String text,
    String? consentToken,
  }) async {
    final language = _languageByThread[threadLocalId] ?? 'en';
    String? streamingMessageId;
    final accumulated = StringBuffer();

    try {
      final stream = _repository.streamMessage(
        text: text,
        language: language,
        citizenId: _citizenPseudonym,
        threadId: _backendThreadIds[threadLocalId],
        consentToken: consentToken,
      );

      await for (final event in stream) {
        switch (event) {
          case StreamStart():
            _backendThreadIds[threadLocalId] = event.threadId;
            _languageByThread[threadLocalId] = event.language;
            break;

          case StreamMessage(:final dto):
            _appendMessage(threadLocalId, dto.toDomain());
            state = state.copyWith(isAssistantTyping: false);
            break;

          case StreamMessageStart(:final messageId):
            streamingMessageId = messageId;
            accumulated.clear();
            _appendMessage(
              threadLocalId,
              ChatMessage(
                id: messageId,
                role: ChatRole.assistant,
                kind: ChatContentKind.text,
                createdAt: DateTime.now(),
                text: '',
                isStreaming: true,
              ),
            );
            state = state.copyWith(isAssistantTyping: false);
            break;

          case StreamDelta(:final messageId, :final text):
            if (messageId != streamingMessageId) break;
            accumulated.write(text);
            _updateMessage(
              threadLocalId,
              messageId,
              (m) => m.copyWith(text: accumulated.toString()),
            );
            break;

          case StreamMessageEnd(:final messageId, :final fullText):
            if (messageId == streamingMessageId) {
              _updateMessage(
                threadLocalId,
                messageId,
                (m) => m.copyWith(text: fullText, isStreaming: false),
              );
              streamingMessageId = null;
            }
            break;

          case StreamDone():
            break;

          case StreamError(:final detail):
            _appendSystemError(threadLocalId, detail);
            return;
        }
      }

      // Defensive: if the server didn't send a message_end (e.g. socket
      // dropped) clear the streaming flag so the cursor stops blinking.
      if (streamingMessageId != null) {
        final captured = streamingMessageId;
        _updateMessage(
          threadLocalId,
          captured,
          (m) => m.copyWith(isStreaming: false),
        );
      }
      state = state.copyWith(isAssistantTyping: false);
    } on AssistantApiException catch (e) {
      _appendSystemError(threadLocalId, e.message);
    } catch (e) {
      _appendSystemError(threadLocalId, 'Unexpected error: $e');
    }
  }

  void _appendMessage(String threadLocalId, ChatMessage message) {
    final current = state.threads.firstWhere(
      (t) => t.id == threadLocalId,
      orElse: () => state.activeThread,
    );
    state = state.copyWith(
      threads: _replaceThread(
        current.copyWith(
          messages: [...current.messages, message],
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  void _updateMessage(
    String threadLocalId,
    String messageId,
    ChatMessage Function(ChatMessage) update,
  ) {
    final current = state.threads.firstWhere(
      (t) => t.id == threadLocalId,
      orElse: () => state.activeThread,
    );
    final messages = [
      for (final m in current.messages)
        if (m.id == messageId) update(m) else m,
    ];
    state = state.copyWith(
      threads: _replaceThread(
        current.copyWith(messages: messages, updatedAt: DateTime.now()),
      ),
    );
  }

  // -- Consent moment ------------------------------------------------------

  Future<void> respondToConsent({
    required String messageId,
    required bool granted,
  }) async {
    final thread = state.activeThread;
    final idx = thread.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final proposal = thread.messages[idx].consentProposal;
    if (proposal == null) return;

    // Mark the proposal message with the decision first, so the card
    // immediately flips from buttons to a status badge regardless of
    // anything else we do below.
    _updateMessage(
      thread.id,
      messageId,
      (m) => m.copyWith(consentDecision: granted),
    );

    if (!granted) {
      _appendMessage(
        thread.id,
        ChatMessage(
          id: _newId(),
          role: ChatRole.assistant,
          kind: ChatContentKind.text,
          createdAt: DateTime.now(),
          text:
              'Understood — I will not check ${proposal.authority}. I can '
              'still walk you through the general procedure, or route you '
              'to a human at the relevant office.',
          actions: const [
            ChatAction(label: 'Route me to a human', actionId: 'handoff'),
          ],
        ),
      );
      return;
    }

    // Granted: record consent against the GUVA gateway, then re-send.
    _appendMessage(
      thread.id,
      ChatMessage(
        id: _newId(),
        role: ChatRole.assistant,
        kind: ChatContentKind.text,
        createdAt: DateTime.now(),
        text:
            'Thank you — recording your consent with ${proposal.authority} '
            'and checking now.',
      ),
    );
    state = state.copyWith(isAssistantTyping: true);

    try {
      final receipt = await _repository.recordConsent(
        proposal: proposal,
        citizenId: _citizenPseudonym,
      );
      final lastText = _lastCitizenText[thread.id];
      if (lastText == null) {
        // Nothing to re-ask; just clear typing.
        state = state.copyWith(isAssistantTyping: false);
        return;
      }
      await _dispatch(
        threadLocalId: thread.id,
        text: lastText,
        consentToken: receipt.consentId,
      );
    } on AssistantApiException catch (e) {
      _appendSystemError(thread.id, e.message);
    } catch (e) {
      _appendSystemError(thread.id, 'Unexpected error: $e');
    }
  }

  // -- Actions -------------------------------------------------------------

  void runAction(String actionId, {String? sourceMessageId}) {
    final thread = state.activeThread;
    if (actionId == 'handoff') {
      final summary = ChatMessage(
        id: _newId(),
        role: ChatRole.assistant,
        kind: ChatContentKind.handoff,
        createdAt: DateTime.now(),
        text:
            'I have prepared a handoff. Your context will be shared with the '
            'office below so you do not have to start over.',
        handoff: const HandoffSummary(
          agency: 'Citizen support desk',
          officeName: 'National Citizens Helpline',
          contact: '0800 100 200',
          contextSummary:
              'Routed from Ask Uganda after the citizen declined a personalised check.',
        ),
      );
      state = state.copyWith(
        threads: _replaceThread(
          thread.copyWith(
            messages: [...thread.messages, summary],
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }
  }

  // -- Helpers -------------------------------------------------------------

  void _appendSystemError(String threadLocalId, String message) {
    final current = state.threads.firstWhere(
      (t) => t.id == threadLocalId,
      orElse: () => state.activeThread,
    );
    final errorMessage = ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text:
          'I could not reach the service just now. Please try again in a '
          'moment. ($message)',
    );
    state = state.copyWith(
      threads: _replaceThread(
        current.copyWith(
          messages: [...current.messages, errorMessage],
          updatedAt: DateTime.now(),
        ),
      ),
      isAssistantTyping: false,
      lastError: message,
    );
  }

  List<ChatThread> _replaceThread(ChatThread updated) {
    return state.threads
        .map((t) => t.id == updated.id ? updated : t)
        .toList(growable: false);
  }

  String _summarise(String text) {
    if (text.length <= 48) return text;
    return '${text.substring(0, 45)}…';
  }

  ChatMessage _introMessage() {
    return ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text:
          'Hello. I am Ask Uganda. I can guide you through any government '
          'service in your language, and — with your consent — verify your '
          'specific situation through GUVA. What would you like help with '
          'today?',
    );
  }
}

final ChatThread _seedThread = ChatThread(
  id: 'seed-thread',
  title: 'Welcome',
  messages: [
    ChatMessage(
      id: 'intro',
      role: ChatRole.assistant,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text:
          'Hello. I am Ask Uganda. I can guide you through any government '
          'service in your language, and — with your consent — verify your '
          'specific situation through GUVA. What would you like help with '
          'today?',
    ),
  ],
  updatedAt: DateTime.now(),
);

final assistantControllerProvider =
    StateNotifierProvider<AssistantController, AssistantState>(
      (ref) => AssistantController(ref.watch(assistantRepositoryProvider)),
    );
