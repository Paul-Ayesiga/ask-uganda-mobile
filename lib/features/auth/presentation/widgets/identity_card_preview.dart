import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class IdentityCardPreview extends StatelessWidget {
  const IdentityCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          border: Border.all(color: AppTheme.line(context)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14123B2A),
              offset: Offset(0, 18),
              blurRadius: 36,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.page(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Citizen identity', style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Protected by consent', style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const _StatusPill(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const _PreviewMetric(
              icon: Icons.history_rounded,
              label: 'Recent verification',
              value: 'Bank account opening',
            ),
            const SizedBox(height: AppSpacing.md),
            const _PreviewMetric(
              icon: Icons.lock_clock_rounded,
              label: 'Active consent',
              value: 'Expires in 29 days',
            ),
            const SizedBox(height: AppSpacing.md),
            const _PreviewMetric(
              icon: Icons.notifications_active_outlined,
              label: 'Security alerts',
              value: 'None requiring action',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          'Secure',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}
