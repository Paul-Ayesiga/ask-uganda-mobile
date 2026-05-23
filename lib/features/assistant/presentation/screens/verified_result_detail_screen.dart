import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/verified_fact.dart';

class VerifiedResultDetailScreen extends StatelessWidget {
  const VerifiedResultDetailScreen({super.key, required this.fact});

  final VerifiedFact fact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Verification details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.flagYellow.withValues(alpha: 0.18),
                border: Border.all(
                  color: AppColors.flagYellow.withValues(alpha: 0.6),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Verified by ${fact.authoritativeSource}',
                          style: textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(fact.title, style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(fact.summary, style: textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                border: Border.all(color: AppTheme.line(context)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fields returned', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  for (var i = 0; i < fact.fields.length; i++) ...[
                    _FieldRow(field: fact.fields[i]),
                    if (i != fact.fields.length - 1)
                      const Divider(height: AppSpacing.lg),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                border: Border.all(color: AppTheme.line(context)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Audit trail', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  _AuditRow(
                    label: 'Request ID',
                    value: fact.requestId,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _AuditRow(
                    label: 'Consent reference',
                    value: fact.consentReference ?? '—',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _AuditRow(
                    label: 'Issued at',
                    value: fact.issuedAt.toIso8601String(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Ask Uganda does not retain a copy of this result beyond '
                    'this conversation. The authoritative record lives in the '
                    'register above.',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        SizedBox(width: 132, child: Text(field.label, style: textTheme.bodyMedium)),
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

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 132, child: Text(label, style: textTheme.bodyMedium)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: SelectableText(value, style: textTheme.titleMedium),
        ),
      ],
    );
  }
}
