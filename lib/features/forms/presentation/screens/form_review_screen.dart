import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/assisted_form.dart';

class FormReviewScreen extends StatelessWidget {
  const FormReviewScreen({
    super.key,
    required this.form,
    required this.values,
  });

  final AssistedForm form;
  final Map<String, String> values;

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
        title: const Text('Review'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Ready to submit', style: textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Please check every answer below before submitting to '
              '${form.responsibleAgency}. Ask Uganda can verify any '
              'GUVA-linked field before submission.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                border: Border.all(color: AppTheme.line(context)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < form.fields.length; i++) ...[
                    _ReviewRow(
                      field: form.fields[i],
                      value: values[form.fields[i].id],
                    ),
                    if (i != form.fields.length - 1)
                      Divider(
                        height: 1,
                        color: AppTheme.line(context),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Submission is sent to ${form.responsibleAgency} over a '
                      'secure channel. Ask Uganda does not retain a copy of '
                      'your answers beyond this conversation.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => _showSubmitted(context),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Submit'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit answers'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitted(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        final textTheme = Theme.of(sheetContext).textTheme;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.line(sheetContext),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Icon(Icons.check_circle_rounded, color: scheme.primary, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Submitted to ${form.responsibleAgency}',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You will receive a notification when there is an update.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.go('/');
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.field, required this.value});

  final AssistedFormField field;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasValue = (value ?? '').trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field.label, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hasValue ? value! : '— not provided',
                  style: textTheme.titleMedium?.copyWith(
                    color: hasValue
                        ? null
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
          if (field.canPrefillViaGuva)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Icon(
                Icons.verified_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
