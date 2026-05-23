import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coat_of_arms_badge.dart';
import '../widgets/lock_loader_mark.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _splashDuration = Duration(milliseconds: 1800);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_splashDuration, _advance);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance() {
    if (!mounted) {
      return;
    }
    final onboardingComplete =
        ref.read(preferencesControllerProvider).onboardingComplete;
    if (onboardingComplete) {
      context.go('/welcome');
    } else {
      context.go('/onboarding/language');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.flagYellow,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const LockLoaderMark(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Ask Uganda',
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.flagBlack,
                        fontSize: 42,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'A patient, multilingual assistant for every government service.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.flagBlack.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Grounded in GUVA — the Government Unified Verification layer',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.flagBlack.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
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
