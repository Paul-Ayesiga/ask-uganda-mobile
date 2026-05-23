import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';

class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Accessibility'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Make Ask Uganda easier to read and use. Voice input and '
              'language settings are configured separately.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                border: Border.all(color: AppTheme.line(context)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Text size', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Slider.adaptive(
                    value: preferences.textScale,
                    min: 0.85,
                    max: 1.6,
                    divisions: 6,
                    label: '×${preferences.textScale.toStringAsFixed(2)}',
                    onChanged: (value) => ref
                        .read(preferencesControllerProvider.notifier)
                        .setTextScale(value),
                  ),
                  Text(
                    'Sample sentence: I would like to renew my National ID.',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 16 * preferences.textScale,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile.adaptive(
              value: preferences.highContrast,
              onChanged: (value) => ref
                  .read(preferencesControllerProvider.notifier)
                  .setHighContrast(value),
              title: const Text('High contrast'),
              subtitle: const Text(
                'Stronger borders and clearer separation between elements.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
