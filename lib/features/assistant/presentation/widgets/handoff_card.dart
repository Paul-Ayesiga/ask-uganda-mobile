import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/chat_message.dart';

class HandoffCard extends StatelessWidget {
  const HandoffCard({super.key, required this.handoff, this.onOpen});

  final HandoffSummary handoff;
  final VoidCallback? onOpen;

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
            color: AppTheme.card(context),
            border: Border.all(color: AppTheme.line(context)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.support_agent_rounded, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Handoff prepared',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(handoff.agency, style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(handoff.officeName, style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              _Row(label: 'Contact', value: handoff.contact),
              const SizedBox(height: AppSpacing.sm),
              _Row(label: 'Shared context', value: handoff.contextSummary),
              if (onOpen != null) ...[
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('View handoff'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 124, child: Text(label, style: textTheme.bodyMedium)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(value, style: textTheme.titleMedium)),
      ],
    );
  }
}
