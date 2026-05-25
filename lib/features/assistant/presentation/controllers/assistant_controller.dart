import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../data/assistant_repository.dart';
import '../../data/conversation_store.dart';
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
  AssistantController(this._ref, this._repository, this._store)
      : super(AssistantState.initial()) {
    // Hydrate from disk in the background. While loading, the UI shows
    // the seed thread; once loaded we splice in the persisted threads
    // and pick the most recently updated one as active.
    unawaited(_hydrate());
  }

  final Ref _ref;
  final AssistantRepository _repository;
  final ConversationStore _store;

  /// Current language preference, read at the moment we need it so a
  /// citizen switching language in Settings affects the very next
  /// new thread or send.
  String get _currentLanguageCode =>
      _ref.read(preferencesControllerProvider).language.code;
  final _idRandom = math.Random();

  // Per-thread bookkeeping that doesn't belong in the UI-facing state.
  final Map<String, String> _backendThreadIds = {};       // local → backend uuid
  final Map<String, String> _languageByThread = {};       // local → language
  final Map<String, String> _lastCitizenText = {};        // for consent retry
  // Structured values the citizen has submitted on this thread via
  // FieldRequest cards. Sent on every subsequent dispatch so the
  // orchestrator gates correctly through the consent moment.
  final Map<String, Map<String, String>> _fieldValuesByThread = {};

  bool _hydrated = false;

  Future<void> _hydrate() async {
    final loaded = await _store.load();
    if (loaded.isEmpty) {
      _hydrated = true;
      return;
    }
    // Order by recency descending so the most active conversation is on top.
    final sorted = [...loaded]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = state.copyWith(
      threads: sorted,
      activeThreadId: sorted.first.id,
    );
    for (final t in sorted) {
      _languageByThread[t.id] = t.languageCode;
    }
    _hydrated = true;
  }

  void _persist() {
    if (!_hydrated) return;
    _store.enqueueSave(state.threads);
  }

  @override
  set state(AssistantState value) {
    super.state = value;
    // Save after every mutation. The store debounces internally so
    // bursts (e.g. a 100-delta streaming reply) coalesce to one write.
    _persist();
  }

  @override
  Future<void> dispose() async {
    await _store.flush();
    super.dispose();
  }

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
    final language = _currentLanguageCode;
    final thread = ChatThread(
      id: _newId(),
      title: 'New conversation',
      messages: [_introMessage()],
      updatedAt: DateTime.now(),
      languageCode: language,
    );
    _languageByThread[thread.id] = language;
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
    // Language preference order:
    //   1. The backend's echo from a previous reply on this thread.
    //   2. The thread's stored languageCode (set when the thread was
    //      created from the citizen's then-current preference).
    //   3. The citizen's current preference — covers the seed thread,
    //      which is created at module load before preferences are
    //      available.
    final thread = state.threads.firstWhere(
      (t) => t.id == threadLocalId,
      orElse: () => state.activeThread,
    );
    final language = _languageByThread[threadLocalId] ??
        (thread.languageCode != 'en' ? thread.languageCode : _currentLanguageCode);
    _languageByThread[threadLocalId] = language;
    String? streamingMessageId;
    final accumulated = StringBuffer();

    try {
      final stream = _repository.streamMessage(
        text: text,
        language: language,
        citizenId: _citizenPseudonym,
        threadId: _backendThreadIds[threadLocalId],
        consentToken: consentToken,
        fieldValues: _fieldValuesByThread[threadLocalId] ?? const {},
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

  // -- Field requests ------------------------------------------------------

  /// Called when the citizen taps Submit on a FieldRequestCard.
  /// Persists the value on the message (so the card flips to a
  /// "Submitted" pill and survives reload), accumulates it for the
  /// thread, and re-dispatches the original question so the orchestrator
  /// can advance past the gate.
  Future<void> submitField({
    required String messageId,
    required String fieldId,
    required String value,
  }) async {
    final thread = state.activeThread;
    final idx = thread.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    final submission = {fieldId: value};

    // 1. Mark the card as submitted in place.
    _updateMessage(
      thread.id,
      messageId,
      (m) => m.copyWith(fieldSubmission: submission),
    );

    // 2. Accumulate for subsequent dispatches.
    final acc = {..._fieldValuesByThread[thread.id] ?? const {}};
    acc[fieldId] = value;
    _fieldValuesByThread[thread.id] = acc;

    // 3. Re-ask the original question; backend will gate to the next
    //    missing field, or proceed to the consent moment.
    final lastText = _lastCitizenText[thread.id];
    if (lastText == null) return;
    state = state.copyWith(isAssistantTyping: true);
    await _dispatch(threadLocalId: thread.id, text: lastText);
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
    final code = _currentLanguageCode;
    return ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text: _introByLanguage[code] ?? _introByLanguage['en']!,
    );
  }
}

/// Localised intro shown when a new thread opens. The English version is
/// the canonical text; other languages are native-speaker-style
/// translations of the same content. Add a new locale here and the
/// language picker immediately picks it up.
const _introByLanguage = <String, String>{
  'en':
      'Hello. I am Ask Uganda. I can guide you through any government '
      'service in your language, and — with your consent — verify your '
      'specific situation through GUVA. What would you like help with '
      'today?',
  'lg':
      'Mwasuze mutya. Nze Ask Uganda. Nsobola okukuyamba ku buli mpeereza '
      'ya gavumenti mu lulimi lwo, era — ng\'okiriza — nkakase embeera '
      'yo egakuluddeko mu GUVA. Kiki ky\'oyagala nkuyambeko leero?',
  'nyn':
      'Agandi. Niinye Ask Uganda. Naasobora kukuhwera aha buri mpereza '
      'ya gavumenti mu rurimi rwawe, kandi — waaba okikiriza — naakakasa '
      'embeera yawe ahabwa GUVA. Niki eki orikwenda nkuhwere leero?',
  'ach':
      'Apwoyo. An aye Ask Uganda. Atwero konyi i kit me bedo ki ticc me '
      'gamente i leb meri, ki — ka iye — niang i kit ma in nutu kwede '
      'kun atiyo ki GUVA. Ango ma imito an akonyi tin?',
  'teo':
      'Eyalama. Eong Ask Uganda. Amina aiwakit ijo ne aitemar ka ngina '
      'gavumenti ka akirekak kon, ka — kineni — aitemar nuyenu kon '
      'kotere GUVA. Inyo ipedoritor ne aiwakitar ijo lolo?',
  'lgg':
      'Mi alenga. Ma ni Ask Uganda. Ma ovule mi azita gavumenti drilea '
      'aza ma ti pini, eyi — ka mi le — ma sasa cuni mi pini drile GUVA. '
      'Ngori ma le ma azipi ru ondre?',
  'sw':
      'Habari. Mimi ni Ask Uganda. Naweza kukusaidia kupitia huduma '
      'yoyote ya serikali kwa lugha yako, na — ukikubali — kuthibitisha '
      'hali yako mahususi kupitia GUVA. Ungependa msaada wa nini leo?',
};

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
      (ref) => AssistantController(
        ref,
        ref.watch(assistantRepositoryProvider),
        ref.watch(conversationStoreProvider),
      ),
    );
