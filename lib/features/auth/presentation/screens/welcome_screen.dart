import 'package:flutter/material.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coat_of_arms_badge.dart';
import '../widgets/identity_card_preview.dart';
import '../widgets/security_signal.dart';
import '../widgets/welcome_actions.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final windowClass = AppBreakpoints.fromWidth(
                  constraints.maxWidth,
                );
                final isDesktop = windowClass == AppWindowClass.desktop;
                final horizontalPadding = switch (windowClass) {
                  AppWindowClass.mobile => AppSpacing.lg,
                  AppWindowClass.tablet => AppSpacing.xxl,
                  AppWindowClass.desktop => 72.0,
                };

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: isDesktop ? AppSpacing.xxl : AppSpacing.lg,
                      ),
                      child: isDesktop
                          ? const _WideWelcomeLayout()
                          : const _CompactWelcomeLayout(),
                    ),
                  ),
                );
              },
            ),
            const Positioned(
              top: AppSpacing.lg,
              right: AppSpacing.lg,
              child: CoatOfArmsBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactWelcomeLayout extends StatelessWidget {
  const _CompactWelcomeLayout();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeHeader(),
          SizedBox(height: AppSpacing.xl),
          IdentityCardPreview(),
          SizedBox(height: AppSpacing.xl),
          WelcomeActions(),
          SizedBox(height: AppSpacing.lg),
          SecuritySignal(),
        ],
      ),
    );
  }
}

class _WideWelcomeLayout extends StatelessWidget {
  const _WideWelcomeLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _WelcomeHeader(),
              SizedBox(height: AppSpacing.xl),
              WelcomeActions(maxWidth: 420),
              SizedBox(height: AppSpacing.lg),
              SecuritySignal(),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.xxl),
        Expanded(flex: 8, child: Center(child: IdentityCardPreview())),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BrandMark(),
        const SizedBox(height: AppSpacing.xxl),
        Text('Ask Uganda', style: textTheme.displaySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'A patient, multilingual assistant for every government service.',
          style: textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(
            'Ask in your own language. Get correct, personalised answers '
            'grounded in authoritative government registers through GUVA.',
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ask Uganda mark',
      child: const SizedBox.square(
        dimension: 64,
        child: Image(
          image: AssetImage('assets/brand/ask-uganda-mark-256.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
