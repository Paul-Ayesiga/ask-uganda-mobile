import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../assistant/presentation/controllers/assistant_controller.dart';
import '../../domain/models/government_service.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.service});

  final GovernmentService service;

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
        title: Text(service.category.label),
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
                    border: Border.all(color: AppTheme.line(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service.category.icon,
                    color: scheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(service.responsibleAgency,
                          style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(service.summary, style: textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            _MetaCard(
              fee: service.fee,
              processingTime: service.processingTime,
              channels: service.deliveryChannels,
              guvaVerified: service.guvaVerificationAvailable,
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Before you start',
              icon: Icons.checklist_rounded,
              children: service.prerequisites
                  .map((p) => _Bullet(text: p))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Steps',
              icon: Icons.timeline_rounded,
              children: [
                for (var i = 0; i < service.steps.length; i++)
                  _NumberedStep(index: i + 1, text: service.steps[i]),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Documents you will need',
              icon: Icons.folder_open_outlined,
              children: service.requiredDocuments
                  .map((d) => _Bullet(text: d))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/documents'),
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Prepare documents'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final id = ref
                          .read(assistantControllerProvider.notifier)
                          .startNewThread();
                      context.push(
                        '/assistant/conversation/$id',
                        extra: {
                          'prompt':
                              'Help me with ${service.name.toLowerCase()}',
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Ask about this'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.fee,
    required this.processingTime,
    required this.channels,
    required this.guvaVerified,
  });

  final String fee;
  final String processingTime;
  final List<String> channels;
  final bool guvaVerified;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border.all(color: AppTheme.line(context)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _MetaRow(
            icon: Icons.payments_outlined,
            label: 'Fee',
            value: fee,
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetaRow(
            icon: Icons.schedule_rounded,
            label: 'Processing time',
            value: processingTime,
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetaRow(
            icon: Icons.alt_route_rounded,
            label: 'Channels',
            value: channels.join(' · '),
          ),
          if (guvaVerified) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: scheme.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Ask Uganda can verify your specific status with the '
                      'register before this service — with your consent.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(width: 124, child: Text(label, style: textTheme.bodyMedium)),
        Expanded(child: Text(value, style: textTheme.titleMedium)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border.all(color: AppTheme.line(context)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 6,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
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
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
