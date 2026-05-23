import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../assistant/domain/models/chat_message.dart';
import '../../../assistant/presentation/controllers/assistant_controller.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantControllerProvider);
    final allMessages = [
      for (final thread in state.threads) ...thread.messages,
    ];

    final verified = allMessages
        .where((m) => m.kind == ChatContentKind.verifiedFact)
        .toList(growable: false);
    final consents = allMessages
        .where((m) => m.kind == ChatContentKind.consentProposal)
        .toList(growable: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Every conversation, consent, and verified result remains '
                    'visible to you.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Conversations'),
                Tab(text: 'Verifications'),
                Tab(text: 'Consents'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ConversationsList(state: state),
                  _VerificationsList(messages: verified),
                  _ConsentsList(messages: consents),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationsList extends ConsumerWidget {
  const _ConversationsList({required this.state});

  final AssistantState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.threads.isEmpty) {
      return _EmptyState(message: 'You have no conversations yet.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: state.threads.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final thread = state.threads[index];
        return _RowCard(
          icon: Icons.chat_outlined,
          title: thread.title,
          subtitle:
              '${thread.messages.length} messages · ${_stamp(thread.updatedAt)}',
          onTap: () {
            ref
                .read(assistantControllerProvider.notifier)
                .selectThread(thread.id);
            context.push('/assistant/conversation/${thread.id}');
          },
        );
      },
    );
  }

  String _stamp(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

class _VerificationsList extends StatelessWidget {
  const _VerificationsList({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _EmptyState(message: 'No verified results yet.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: messages.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final fact = messages[index].verifiedFact!;
        return _RowCard(
          icon: Icons.verified_outlined,
          title: fact.title,
          subtitle:
              '${fact.authoritativeSource} · ${fact.issuedAt.hour.toString().padLeft(2, '0')}:${fact.issuedAt.minute.toString().padLeft(2, '0')}',
          onTap: () =>
              context.push('/assistant/verified', extra: fact),
        );
      },
    );
  }
}

class _ConsentsList extends StatelessWidget {
  const _ConsentsList({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _EmptyState(message: 'No consent requests yet.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: messages.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final proposal = messages[index].consentProposal!;
        return _RowCard(
          icon: Icons.fact_check_outlined,
          title: proposal.authority,
          subtitle: proposal.purpose,
          onTap: () {},
        );
      },
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.line(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.page(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
