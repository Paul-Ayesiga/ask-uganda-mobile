import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../assistant/presentation/controllers/assistant_controller.dart';
import '../../../services_directory/domain/models/government_service.dart';
import '../../domain/models/life_event.dart';

class LifeEventPlanScreen extends ConsumerWidget {
  const LifeEventPlanScreen({super.key, required this.event});

  final LifeEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Life event plan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.line(context)),
                  ),
                  child: Icon(event.icon, color: scheme.primary, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.label, style: textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${event.steps.length} guided steps · ${_uniqueAgencies(event).join(' · ')}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(event.summary, style: textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < event.steps.length; i++)
              _StepCard(
                index: i + 1,
                step: event.steps[i],
                isLast: i == event.steps.length - 1,
                onOpenService: () {
                  final id = event.steps[i].serviceId;
                  if (id == null) return;
                  final service = ServicesCatalogue.all.firstWhere(
                    (s) => s.id == id,
                    orElse: () => ServicesCatalogue.all.first,
                  );
                  context.push('/services/${service.id}', extra: service);
                },
              ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                final id = ref
                    .read(assistantControllerProvider.notifier)
                    .startNewThread();
                context.push(
                  '/assistant/conversation/$id',
                  extra: {
                    'prompt':
                        'Help me work through "${event.label}" step by step.',
                  },
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Walk me through this with Ask Uganda'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _uniqueAgencies(LifeEvent event) {
    final s = <String>{};
    for (final step in event.steps) {
      s.add(step.responsibleAgency);
    }
    return s.toList();
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.isLast,
    required this.onOpenService,
  });

  final int index;
  final LifeEventStep step;
  final bool isLast;
  final VoidCallback onOpenService;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppTheme.line(context),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  border: Border.all(color: AppTheme.line(context)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(step.summary, style: textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          size: 16,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          step.responsibleAgency,
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (step.serviceId != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onOpenService,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Open service'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
