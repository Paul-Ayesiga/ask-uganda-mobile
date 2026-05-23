import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ask_uganda_brand_mark.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        title: const Text('About Ask Uganda'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AskUgandaBrandMark(
                        size: 44,
                        variant: AskUgandaBrandVariant.squircleIcon,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        AppStrings.productName,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.productTagline,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppStrings.productLongTagline,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Grounding discipline',
              icon: Icons.shield_outlined,
              body:
                  'Every claim about your records is verified live against the '
                  'authoritative register through GUVA. Procedural answers '
                  'come from a curated government knowledge base. The language '
                  'model never invents facts about you.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Sovereignty',
              icon: Icons.flag_outlined,
              body:
                  'The language model and speech services run on '
                  'government-controlled infrastructure. Citizens’ questions '
                  'are not routed to third-party APIs outside the country.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Data minimisation',
              icon: Icons.lock_outline_rounded,
              body:
                  'Ask Uganda does not retain a copy of your verified records. '
                  'Authoritative data lives in the source register and is '
                  'accessed only at the moment of need, with your consent.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'How it works with GUVA',
              icon: Icons.hub_outlined,
              body:
                  'Ask Uganda is an authorised consumer of the Government '
                  'Unified Verification API. Every verification request follows '
                  'the same documented controls, consent, and audit as any '
                  'other GUVA consumer.',
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                border: Border.all(color: AppTheme.line(context)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.code_rounded, color: scheme.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Build', style: textTheme.titleMedium),
                        Text(
                          'Version 1.0.0 · May 2026',
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
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.body});

  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
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
              Icon(icon, color: scheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
