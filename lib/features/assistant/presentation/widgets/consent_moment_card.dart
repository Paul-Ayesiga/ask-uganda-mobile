import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/consent_proposal.dart';

class ConsentMomentCard extends StatelessWidget {
  const ConsentMomentCard({
    super.key,
    required this.proposal,
    required this.onAllow,
    required this.onDecline,
    this.decision,
  });

  final ConsentProposal proposal;
  final VoidCallback onAllow;
  final VoidCallback onDecline;

  /// null  → buttons (citizen hasn't decided)
  /// true  → green tick + "Consent granted"
  /// false → red cross + "Consent declined"
  final bool? decision;

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
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.flagYellow.withValues(alpha: 0.12),
            border: Border.all(
              color: AppColors.flagYellow.withValues(alpha: 0.55),
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Consent required',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ask Uganda is about to check the register before answering. '
                'Please review what will be checked and why.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.line(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetaRow(label: 'Authority', value: proposal.authority),
                    const SizedBox(height: AppSpacing.sm),
                    _MetaRow(label: 'Purpose', value: proposal.purpose),
                    const SizedBox(height: AppSpacing.sm),
                    _MetaRow(
                      label: 'Valid for',
                      value: '${proposal.validForMinutes} minutes',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'What will be checked',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final scope in proposal.scopes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(scope.label, style: textTheme.titleMedium),
                                  const SizedBox(height: 2),
                                  Text(
                                    scope.purpose,
                                    style: textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (decision == null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDecline,
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onAllow,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Allow'),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(
                      decision == true
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: decision == true ? scheme.primary : scheme.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      decision == true ? 'Consent granted' : 'Consent declined',
                      style: textTheme.labelLarge?.copyWith(
                        color: decision == true ? scheme.primary : scheme.error,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 92, child: Text(label, style: textTheme.bodyMedium)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(value, style: textTheme.titleMedium)),
      ],
    );
  }
}
