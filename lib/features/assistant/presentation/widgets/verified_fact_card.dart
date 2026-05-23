import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/verified_fact.dart';

class VerifiedFactCard extends StatelessWidget {
  const VerifiedFactCard({super.key, required this.fact, this.onOpenDetail});

  final VerifiedFact fact;
  final VoidCallback? onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.55),
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Verified by ${fact.authoritativeSource}',
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(fact.issuedAt),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fact.title, style: textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(fact.summary, style: textTheme.bodyMedium),
                    if (fact.fields.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppTheme.page(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.line(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < fact.fields.length; i++) ...[
                              _FieldRow(field: fact.fields[i]),
                              if (i != fact.fields.length - 1)
                                Divider(
                                  height: AppSpacing.lg,
                                  color: AppTheme.line(context),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (onOpenDetail != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onOpenDetail,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('View verification details'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field});

  final VerifiedField field;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(field.label, style: textTheme.bodyMedium),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.value, style: textTheme.titleMedium),
              if (field.note != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  field.note!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
