import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_thread.dart';
import '../../domain/models/consent_proposal.dart';
import '../../domain/models/verified_fact.dart';

@immutable
class AssistantState {
  const AssistantState({
    required this.threads,
    required this.activeThreadId,
    required this.isAssistantTyping,
    this.activeConsentProposalMessageId,
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
  final String? activeConsentProposalMessageId;

  ChatThread get activeThread =>
      threads.firstWhere((t) => t.id == activeThreadId);

  AssistantState copyWith({
    List<ChatThread>? threads,
    String? activeThreadId,
    bool? isAssistantTyping,
    Object? activeConsentProposalMessageId = _sentinel,
  }) {
    return AssistantState(
      threads: threads ?? this.threads,
      activeThreadId: activeThreadId ?? this.activeThreadId,
      isAssistantTyping: isAssistantTyping ?? this.isAssistantTyping,
      activeConsentProposalMessageId:
          identical(activeConsentProposalMessageId, _sentinel)
          ? this.activeConsentProposalMessageId
          : activeConsentProposalMessageId as String?,
    );
  }
}

const _sentinel = Object();

class AssistantController extends StateNotifier<AssistantState> {
  AssistantController() : super(AssistantState.initial());

  final _idRandom = math.Random();
  Timer? _typingTimer;

  String _newId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_idRandom.nextInt(1 << 32)}';
  }

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
    );
    return thread.id;
  }

  void sendCitizenMessage(String text) {
    if (text.trim().isEmpty) return;
    final thread = state.activeThread;
    final citizenMessage = ChatMessage(
      id: _newId(),
      role: ChatRole.citizen,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text: text.trim(),
    );
    final updatedThread = thread.copyWith(
      title: thread.messages.length <= 1 ? _summarise(text.trim()) : thread.title,
      messages: [...thread.messages, citizenMessage],
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      threads: _replaceThread(updatedThread),
      isAssistantTyping: true,
    );

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1100), () {
      _composeAssistantResponse(text.trim());
    });
  }

  void respondToConsent({required String messageId, required bool granted}) {
    final thread = state.activeThread;
    final messages = [...thread.messages];
    final proposalIndex = messages.indexWhere((m) => m.id == messageId);
    if (proposalIndex == -1) return;
    final proposal = messages[proposalIndex].consentProposal;
    if (proposal == null) return;

    if (granted) {
      // Replace proposal with consent-granted note + verified fact
      final grantedNote = ChatMessage(
        id: _newId(),
        role: ChatRole.assistant,
        kind: ChatContentKind.text,
        createdAt: DateTime.now(),
        text:
            'Thank you — I have recorded your consent through GUVA. Checking '
            '${proposal.authority} now.',
      );
      messages.insert(proposalIndex + 1, grantedNote);
      state = state.copyWith(
        threads: _replaceThread(
          thread.copyWith(messages: messages, updatedAt: DateTime.now()),
        ),
        activeConsentProposalMessageId: null,
        isAssistantTyping: true,
      );

      Timer(const Duration(milliseconds: 1400), () {
        final factThread = state.activeThread;
        final verified = _verifiedFactForProposal(proposal);
        final factMessage = ChatMessage(
          id: _newId(),
          role: ChatRole.assistant,
          kind: ChatContentKind.verifiedFact,
          createdAt: DateTime.now(),
          verifiedFact: verified,
          text:
              'Here is what the register returned. The facts below are verified '
              'against ${verified.authoritativeSource} as of just now.',
        );
        final updated = factThread.copyWith(
          messages: [...factThread.messages, factMessage],
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(
          threads: _replaceThread(updated),
          isAssistantTyping: false,
        );
      });
    } else {
      final declined = ChatMessage(
        id: _newId(),
        role: ChatRole.assistant,
        kind: ChatContentKind.text,
        createdAt: DateTime.now(),
        text:
            'Understood — I will not check ${proposal.authority}. I can still '
            'walk you through the general procedure, or route you to a human at '
            'the relevant office.',
        actions: const [
          ChatAction(label: 'Route me to a human', actionId: 'handoff'),
        ],
      );
      messages.insert(proposalIndex + 1, declined);
      state = state.copyWith(
        threads: _replaceThread(
          thread.copyWith(messages: messages, updatedAt: DateTime.now()),
        ),
        activeConsentProposalMessageId: null,
      );
    }
  }

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
          agency: 'Uganda Driver Licensing System',
          officeName: 'Kampala Central service point',
          contact: '+256 414 320 600',
          contextSummary:
              'Citizen wants to renew expired driving permit. Identity not '
              'verified in this session.',
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

  void _composeAssistantResponse(String citizenText) {
    final thread = state.activeThread;
    final lowered = citizenText.toLowerCase();

    final ChatMessage assistantMessage;
    if (lowered.contains('permit') ||
        lowered.contains('licence') ||
        lowered.contains('license') ||
        lowered.contains('drive')) {
      assistantMessage = _permitGuidanceMessage();
    } else if (lowered.contains('business') ||
        lowered.contains('register') ||
        lowered.contains('company')) {
      assistantMessage = _businessGuidanceMessage();
    } else if (lowered.contains('passport') ||
        lowered.contains('travel')) {
      assistantMessage = _passportGuidanceMessage();
    } else if (lowered.contains('tax') ||
        lowered.contains('tin') ||
        lowered.contains('ura')) {
      assistantMessage = _taxGuidanceMessage();
    } else if (lowered.contains('birth') ||
        lowered.contains('certificate')) {
      assistantMessage = _birthCertificateGuidanceMessage();
    } else {
      assistantMessage = _genericGuidanceMessage(citizenText);
    }

    final updated = thread.copyWith(
      messages: [...thread.messages, assistantMessage],
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      threads: _replaceThread(updated),
      isAssistantTyping: false,
    );

    if (assistantMessage.kind == ChatContentKind.consentProposal) {
      state = state.copyWith(
        activeConsentProposalMessageId: assistantMessage.id,
      );
    }
  }

  ChatMessage _permitGuidanceMessage() {
    return ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.consentProposal,
      createdAt: DateTime.now(),
      text:
          'To renew a driving permit you generally need your National ID, your '
          'current permit, the renewal fee, and your medical certificate if '
          'asked. If you would like, I can check your specific permit status '
          'against the Uganda Driver Licensing System through GUVA.',
      consentProposal: const ConsentProposal(
        id: 'cp-permit',
        authority: 'Uganda Driver Licensing System',
        purpose: 'Advise on renewal of your driving permit',
        scopes: [
          ConsentScope(
            kind: ConsentScopeKind.identity,
            label: 'Confirm identity with NIRA',
            purpose: 'Match your National ID to your name and date of birth',
          ),
          ConsentScope(
            kind: ConsentScopeKind.qualification,
            label: 'Check driving permit status',
            purpose: 'Confirm expiry date and any blocking conditions',
          ),
        ],
        validForMinutes: 15,
      ),
    );
  }

  ChatMessage _businessGuidanceMessage() {
    return ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text:
          'Registering a business in Uganda generally involves URSB business '
          'name reservation, registration, a tax identification number with '
          'URA, and any sector-specific licensing. I can map this as a step-by-'
          'step plan for your situation, or check whether a name you have in '
          'mind is available.',
      actions: const [
        ChatAction(label: 'Show me the full plan', actionId: 'life-event-business'),
        ChatAction(label: 'Check a business name', actionId: 'verify-business'),
      ],
    );
  }

  ChatMessage _passportGuidanceMessage() {
    return ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.consentProposal,
      createdAt: DateTime.now(),
      text:
          'Passport renewal usually requires your existing passport, a National '
          'ID, and the renewal fee. With your consent I can verify your '
          'identity against NIRA and confirm whether anything would block the '
          'application.',
      consentProposal: const ConsentProposal(
        id: 'cp-passport',
        authority: 'Directorate of Citizenship and Immigration Control',
        purpose: 'Confirm your eligibility to renew a passport',
        scopes: [
          ConsentScope(
            kind: ConsentScopeKind.identity,
            label: 'Confirm identity with NIRA',
            purpose: 'Match your National ID to your name and date of birth',
          ),
        ],
        validForMinutes: 15,
      ),
    );
  }

  ChatMessage _taxGuidanceMessage() {
    return ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.consentProposal,
      createdAt: DateTime.now(),
      text:
          'I can ask URA for your tax compliance status. This returns whether '
          'your TIN is currently compliant — it does not show transaction-level '
          'detail.',
      consentProposal: const ConsentProposal(
        id: 'cp-tax',
        authority: 'Uganda Revenue Authority (URA)',
        purpose: 'Check compliance status of your TIN',
        scopes: [
          ConsentScope(
            kind: ConsentScopeKind.taxStatus,
            label: 'Check tax compliance status',
            purpose: 'Confirm whether your TIN is currently compliant',
          ),
        ],
        validForMinutes: 15,
      ),
    );
  }

  ChatMessage _birthCertificateGuidanceMessage() {
    return ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text:
          'To obtain a birth certificate you can apply through NIRA, providing '
          'the child’s notification of birth, the parents’ National IDs, and '
          'the prescribed fee. Would you like me to walk you through the form '
          'step by step?',
      actions: const [
        ChatAction(label: 'Walk me through the form', actionId: 'form-birth-certificate'),
      ],
    );
  }

  ChatMessage _genericGuidanceMessage(String citizenText) {
    return ChatMessage(
      id: _newId(),
      role: ChatRole.assistant,
      kind: ChatContentKind.text,
      createdAt: DateTime.now(),
      text:
          'I want to make sure I help you correctly. To stay accurate I only '
          'speak from curated government information and from verified records '
          'through GUVA. Could you tell me a little more about what you want '
          'to achieve so I can route you to the right service?',
    );
  }

  VerifiedFact _verifiedFactForProposal(ConsentProposal proposal) {
    final now = DateTime.now();
    switch (proposal.id) {
      case 'cp-permit':
        return VerifiedFact(
          title: 'Driving permit status',
          summary:
              'Your permit expired on 12 February 2026. No obstacles to renewal '
              'are recorded. Renewal fee is UGX 60,000.',
          fields: [
            const VerifiedField(label: 'Full name', value: 'Amina Nakato'),
            const VerifiedField(label: 'Permit class', value: 'B (private)'),
            const VerifiedField(
              label: 'Expired on',
              value: '12 February 2026',
              note: 'Two months overdue — late penalty may apply',
            ),
            const VerifiedField(
              label: 'Renewal fee',
              value: 'UGX 60,000',
            ),
            const VerifiedField(
              label: 'Service point',
              value: 'UDLS Kampala Central',
            ),
          ],
          authoritativeSource: 'NIRA + Uganda Driver Licensing System',
          issuedAt: now,
          requestId: 'req-${now.millisecondsSinceEpoch}',
          consentReference: 'csn-${proposal.id}',
        );
      case 'cp-passport':
        return VerifiedFact(
          title: 'Identity confirmed',
          summary:
              'Your identity matches the National Register. No obstacles to a '
              'passport renewal are recorded.',
          fields: [
            const VerifiedField(label: 'Full name', value: 'Amina Nakato'),
            const VerifiedField(label: 'Date of birth', value: '14 April 1994'),
            const VerifiedField(label: 'National ID', value: 'CM********1234'),
          ],
          authoritativeSource: 'NIRA',
          issuedAt: now,
          requestId: 'req-${now.millisecondsSinceEpoch}',
          consentReference: 'csn-${proposal.id}',
        );
      case 'cp-tax':
        return VerifiedFact(
          title: 'Tax compliance status',
          summary:
              'Your TIN is currently compliant. The next review is scheduled '
              'for 20 August 2026.',
          fields: [
            const VerifiedField(label: 'TIN', value: '1000123456'),
            const VerifiedField(label: 'Status', value: 'Compliant'),
            const VerifiedField(label: 'As of', value: '20 May 2026'),
            const VerifiedField(label: 'Next review', value: '20 August 2026'),
          ],
          authoritativeSource: 'Uganda Revenue Authority (URA)',
          issuedAt: now,
          requestId: 'req-${now.millisecondsSinceEpoch}',
          consentReference: 'csn-${proposal.id}',
        );
      default:
        return VerifiedFact(
          title: 'Verified result',
          summary: 'The register returned the requested confirmation.',
          fields: const [],
          authoritativeSource: proposal.authority,
          issuedAt: now,
          requestId: 'req-${now.millisecondsSinceEpoch}',
          consentReference: 'csn-${proposal.id}',
        );
    }
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

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
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
      (ref) => AssistantController(),
    );
