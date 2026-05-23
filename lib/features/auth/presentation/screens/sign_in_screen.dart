import 'package:flutter/material.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coat_of_arms_badge.dart';
import '../widgets/sign_in_form.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: isDesktop ? AppSpacing.xxl : AppSpacing.lg,
                      ),
                      child: isDesktop
                          ? const _WideSignInLayout()
                          : const _CompactSignInLayout(),
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

class _CompactSignInLayout extends StatelessWidget {
  const _CompactSignInLayout();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackButton(),
          SizedBox(height: AppSpacing.xl),
          _SignInHeader(),
          SizedBox(height: AppSpacing.xl),
          SignInForm(),
          SizedBox(height: AppSpacing.lg),
          _SecurityNote(),
        ],
      ),
    );
  }
}

class _WideSignInLayout extends StatelessWidget {
  const _WideSignInLayout();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BackButton(),
              SizedBox(height: AppSpacing.xl),
              _SignInHeader(),
              SizedBox(height: AppSpacing.lg),
              _SecurityNote(),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.xxl),
        Expanded(flex: 6, child: Center(child: SignInForm())),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }
}

class _SignInHeader extends StatelessWidget {
  const _SignInHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sign in securely', style: textTheme.displaySmall),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            'Access your consent requests, verification history, and identity '
            'security controls using your registered citizen credentials.',
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your session is protected by encrypted sign in and audit logging',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          border: Border.all(color: AppTheme.line(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Every sign-in and consent action is protected and recorded '
                'for your visibility.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
