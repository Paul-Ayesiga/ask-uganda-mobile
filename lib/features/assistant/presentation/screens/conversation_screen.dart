import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/voice/voice_service.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/verified_fact.dart';
import '../controllers/assistant_controller.dart';
import '../widgets/assistant_bubble.dart';
import '../widgets/citizen_bubble.dart';
import '../widgets/composer_bar.dart';
import '../widgets/consent_moment_card.dart';
import '../widgets/field_request_card.dart';
import '../widgets/handoff_card.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/verified_fact_card.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, this.initialPrompt});

  final String? initialPrompt;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _initialPromptSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialPromptSent && (widget.initialPrompt ?? '').trim().isNotEmpty) {
        _initialPromptSent = true;
        ref
            .read(assistantControllerProvider.notifier)
            .sendCitizenMessage(widget.initialPrompt!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// When the citizen has voice-first input on, read every newly-completed
  /// assistant text message aloud. We detect "newly completed" by finding
  /// any message that was streaming in the previous state and is no
  /// longer streaming in the next.
  void _maybeAutoSpeak(AssistantState? previous, AssistantState next) {
    final prefs = ref.read(preferencesControllerProvider);
    if (!prefs.voiceFirst) return;
    if (previous == null) return;

    final prevById = {
      for (final m in previous.activeThread.messages) m.id: m,
    };
    for (final m in next.activeThread.messages) {
      if (m.kind != ChatContentKind.text) continue;
      if (m.role != ChatRole.assistant) continue;
      if (m.isStreaming) continue;
      final wasStreaming = prevById[m.id]?.isStreaming ?? false;
      if (!wasStreaming) continue;
      final text = m.text?.trim();
      if (text == null || text.isEmpty) continue;
      ref
          .read(voiceServiceProvider)
          .speak(text, languageCode: next.activeThread.languageCode);
      // Only one auto-speak per state delta.
      return;
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.microtask(() {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantControllerProvider);
    final preferences = ref.watch(preferencesControllerProvider);
    final messages = state.activeThread.messages;

    ref.listen(assistantControllerProvider, (previous, next) {
      _scrollToBottom();
      _maybeAutoSpeak(previous, next);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.activeThread.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Grounded in GUVA · ${preferences.language.englishName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New conversation',
            onPressed: () {
              ref.read(assistantControllerProvider.notifier).startNewThread();
            },
            icon: const Icon(Icons.add_comment_outlined),
          ),
          IconButton(
            tooltip: 'Conversation history',
            onPressed: () => context.push('/conversations'),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              itemCount: messages.length + (state.isAssistantTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && state.isAssistantTyping) {
                  return const TypingIndicator();
                }
                final message = messages[index];
                return _MessageBuilder(message: message);
              },
            ),
          ),
          ComposerBar(
            enabled: !state.isAssistantTyping,
            languageLabel: preferences.language.englishName,
            onChangeLanguage: () => context.push('/settings/language'),
            onSend: (text) {
              ref
                  .read(assistantControllerProvider.notifier)
                  .sendCitizenMessage(text);
            },
            onVoice: () => context.push('/assistant/voice'),
            onAttachDocument: () => context.push('/documents'),
          ),
        ],
      ),
    );
  }
}

class _MessageBuilder extends ConsumerWidget {
  const _MessageBuilder({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (message.kind) {
      case ChatContentKind.text:
        if (message.role == ChatRole.citizen) {
          return CitizenBubble(text: message.text ?? '');
        }
        return AssistantBubble(
          text: message.text ?? '',
          actions: message.actions,
          isStreaming: message.isStreaming,
          onAction: (action) {
            ref
                .read(assistantControllerProvider.notifier)
                .runAction(action.actionId, sourceMessageId: message.id);
          },
        );
      case ChatContentKind.verifiedFact:
        final fact = message.verifiedFact;
        if (fact == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((message.text ?? '').isNotEmpty)
              AssistantBubble(text: message.text!),
            VerifiedFactCard(
              fact: fact,
              onOpenDetail: () => _openVerifiedDetail(context, fact),
            ),
          ],
        );
      case ChatContentKind.consentProposal:
        final proposal = message.consentProposal;
        if (proposal == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((message.text ?? '').isNotEmpty)
              AssistantBubble(text: message.text!),
            ConsentMomentCard(
              proposal: proposal,
              decision: message.consentDecision,
              onAllow: () {
                ref
                    .read(assistantControllerProvider.notifier)
                    .respondToConsent(
                      messageId: message.id,
                      granted: true,
                    );
              },
              onDecline: () {
                ref
                    .read(assistantControllerProvider.notifier)
                    .respondToConsent(
                      messageId: message.id,
                      granted: false,
                    );
              },
            ),
          ],
        );
      case ChatContentKind.handoff:
        final handoff = message.handoff;
        if (handoff == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((message.text ?? '').isNotEmpty)
              AssistantBubble(text: message.text!),
            HandoffCard(
              handoff: handoff,
              onOpen: () => context.push('/handoff'),
            ),
          ],
        );
      case ChatContentKind.fieldRequest:
        final request = message.fieldRequest;
        if (request == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((message.text ?? '').isNotEmpty)
              AssistantBubble(text: message.text!),
            FieldRequestCard(
              request: request,
              submission: message.fieldSubmission,
              onSubmit: (value) {
                ref.read(assistantControllerProvider.notifier).submitField(
                      messageId: message.id,
                      fieldId: request.id,
                      value: value,
                    );
              },
            ),
          ],
        );
      case ChatContentKind.action:
        return const SizedBox.shrink();
    }
  }

  void _openVerifiedDetail(BuildContext context, VerifiedFact fact) {
    context.push('/assistant/verified', extra: fact);
  }
}
