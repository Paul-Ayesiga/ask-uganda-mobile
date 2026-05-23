import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';

class VoiceSettingsScreen extends ConsumerWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Voice and audio'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Configure how voice input and audio playback behave. These '
              'settings work alongside your chosen language.',
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
                children: [
                  SwitchListTile.adaptive(
                    value: preferences.voiceFirst,
                    onChanged: (value) => ref
                        .read(preferencesControllerProvider.notifier)
                        .setVoiceFirst(value),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Voice-first input'),
                    subtitle: const Text(
                      'Start each new conversation with the microphone open.',
                    ),
                  ),
                  Divider(color: AppTheme.line(context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.speed_rounded, color: scheme.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Playback voice',
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Sovereign neural voice for your language.',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
                          value: 'Adult, neutral',
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Adult, neutral',
                              child: Text('Adult, neutral'),
                            ),
                            DropdownMenuItem(
                              value: 'Adult, warm',
                              child: Text('Adult, warm'),
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
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
                      'Speech recognition runs on government-controlled '
                      'infrastructure. Audio is processed only for the duration '
                      'of your request and is not retained.',
                      style: textTheme.bodyMedium,
                    ),
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
