import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_languages.dart';
import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';

class LanguagePreferenceScreen extends ConsumerWidget {
  const LanguagePreferenceScreen({super.key, this.isOnboarding = false});

  final bool isOnboarding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: isOnboarding
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
              ),
        title: const Text('Language'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnboarding
                        ? 'Which language should we use?'
                        : 'Change your language',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isOnboarding
                        ? 'Ask Uganda will speak to you in this language. You can change it any time.'
                        : 'Ask Uganda will respond in this language. Voice support varies — some languages are still in development.',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                itemCount: AppLanguages.all.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final lang = AppLanguages.all[index];
                  final isSelected = lang.code == preferences.language.code;
                  return Material(
                    color: AppTheme.card(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected
                            ? scheme.primary
                            : AppTheme.line(context),
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => ref
                          .read(preferencesControllerProvider.notifier)
                          .setLanguage(lang),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppTheme.page(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lang.code.toUpperCase(),
                                style: textTheme.titleMedium?.copyWith(
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.englishName,
                                    style: textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${lang.nativeName} · ${lang.region}',
                                    style: textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            if (lang.voiceReady)
                              Icon(
                                Icons.mic_rounded,
                                size: 18,
                                color: scheme.primary,
                              ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? scheme.primary
                                  : AppTheme.muted(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isOnboarding)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(preferencesControllerProvider.notifier)
                        .completeOnboarding();
                    context.go('/');
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Continue'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
