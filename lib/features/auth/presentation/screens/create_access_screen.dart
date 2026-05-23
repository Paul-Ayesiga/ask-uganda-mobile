import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coat_of_arms_badge.dart';
import '../widgets/sign_in_form.dart';

class CreateAccessScreen extends StatelessWidget {
  const CreateAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const _CreateAccessForm(),
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

class _CreateAccessForm extends StatelessWidget {
  const _CreateAccessForm();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(right: 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create access',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Submit your National ID number, a selfie, and both sides of your ID to verify your citizen account.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Identity documents',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(16),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'National ID number',
                    hintText: 'CM12345678901234',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const _UploadTile(
                  icon: Icons.face_retouching_natural_outlined,
                  title: 'Selfie',
                  subtitle: 'Clear face photo with good lighting',
                ),
                const SizedBox(height: AppSpacing.md),
                const _UploadTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Front of National ID',
                  subtitle: 'Capture the side with your photo and ID number',
                ),
                const SizedBox(height: AppSpacing.md),
                const _UploadTile(
                  icon: Icons.flip_to_back_rounded,
                  title: 'Back of National ID',
                  subtitle: 'Capture the side with barcode and issue details',
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () => _openVerificationResult(context, true),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Submit verification'),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => _openVerificationResult(context, false),
                  icon: const Icon(Icons.report_gmailerrorred_rounded),
                  label: const Text('Preview unsuccessful state'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.page(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.line(context)),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_photo_alternate_outlined),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationResultScreen extends StatelessWidget {
  const VerificationResultScreen({super.key, required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final title = success ? 'Verification successful' : 'Verification failed';
    final subtitle = success
        ? 'Your identity documents matched. Set an Access PIN to protect future sign-ins.'
        : 'We could not match the details submitted. Retake the selfie and make sure your ID images are clear.';
    final icon = success ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final color = success
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const Spacer(),
                  Icon(icon, color: color, size: 72),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (success)
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          _smoothRoute(const SetAccessPinScreen()),
                        );
                      },
                      icon: const Icon(Icons.password_rounded),
                      label: const Text('Set Access PIN'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Try again'),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to start'),
                  ),
                  const Spacer(),
                ],
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

class SetAccessPinScreen extends StatelessWidget {
  const SetAccessPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Set Access PIN',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Choose a numeric PIN you will use when signing in with your National ID.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SegmentedCodeField(
                          label: 'New Access PIN',
                          length: 4,
                          obscureInitially: true,
                          canToggleVisibility: true,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const SegmentedCodeField(
                          label: 'Confirm PIN',
                          length: 4,
                          obscureInitially: true,
                          canToggleVisibility: true,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Finish setup'),
                        ),
                      ],
                    ),
                  ),
                ],
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

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border.all(color: AppTheme.line(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

void _openVerificationResult(BuildContext context, bool success) {
  Navigator.of(
    context,
  ).push(_smoothRoute(VerificationResultScreen(success: success)));
}

PageRouteBuilder<void> _smoothRoute(Widget screen) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
