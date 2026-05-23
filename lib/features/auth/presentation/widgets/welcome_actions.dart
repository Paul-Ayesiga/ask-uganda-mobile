import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class WelcomeActions extends StatelessWidget {
  const WelcomeActions({super.key, this.maxWidth});

  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: () => context.push('/sign-in'),
          icon: const Icon(Icons.login_rounded),
          label: const Text('Sign in'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('Continue as guest'),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Use biometrics'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: () {},
              tooltip: 'Help',
              icon: const Icon(Icons.help_outline_rounded),
            ),
          ],
        ),
      ],
    );

    if (maxWidth == null) {
      return actions;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: actions,
    );
  }
}
