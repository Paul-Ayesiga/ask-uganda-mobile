import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SecuritySignal extends StatelessWidget {
  const SecuritySignal({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Secured with OpenID Connect, device biometrics, and audit logs',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.enhanced_encryption_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Secured sign-in, biometric protection, and immutable audit history.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
