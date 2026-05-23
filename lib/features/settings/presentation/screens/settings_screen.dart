import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesControllerProvider);
    final themeController = ThemeControllerScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Language and voice', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _Tile(
              icon: Icons.translate_rounded,
              title: 'Language',
              subtitle:
                  '${preferences.language.englishName} · '
                  '${preferences.language.nativeName}',
              onTap: () => context.push('/settings/language'),
            ),
            _Tile(
              icon: Icons.record_voice_over_outlined,
              title: 'Voice and audio',
              subtitle: preferences.voiceFirst
                  ? 'Voice-first input is on'
                  : 'Text-first with optional voice',
              onTap: () => context.push('/settings/voice'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Appearance', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                border: Border.all(color: AppTheme.line(context)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Theme', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.phone_iphone_rounded),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeController.themeMode},
                    onSelectionChanged: (selection) {
                      themeController.onThemeModeChanged(selection.first);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Tile(
              icon: Icons.accessibility_new_rounded,
              title: 'Accessibility',
              subtitle: preferences.highContrast
                  ? 'High contrast on · text scale ×${preferences.textScale.toStringAsFixed(1)}'
                  : 'Default contrast · text scale ×${preferences.textScale.toStringAsFixed(1)}',
              onTap: () => context.push('/settings/accessibility'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Data and trust', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _Tile(
              icon: Icons.policy_outlined,
              title: 'Consents and verifications',
              subtitle: 'Review past consents and verification activity',
              onTap: () => context.push('/activity'),
            ),
            _Tile(
              icon: Icons.cloud_off_outlined,
              title: 'Offline mode',
              subtitle: 'Procedural answers cached for low-connectivity use',
              onTap: () => context.push('/settings/offline'),
            ),
            _Tile(
              icon: Icons.info_outline_rounded,
              title: 'About Ask Uganda',
              subtitle: 'Sovereignty, grounding discipline, and the GUVA layer',
              onTap: () => context.push('/settings/about'),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => context.go('/welcome'),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppTheme.card(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppTheme.line(context)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
