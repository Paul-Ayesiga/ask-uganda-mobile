import 'package:flutter/material.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/coat_of_arms_badge.dart';
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
          SizedBox(height: AppSpacing.xxl),
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _WelcomeHeader(),
            SizedBox(height: AppSpacing.xxl),
            WelcomeActions(maxWidth: 420),
            SizedBox(height: AppSpacing.lg),
            SecuritySignal(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatefulWidget {
  const _WelcomeHeader();

  @override
  State<_WelcomeHeader> createState() => _WelcomeHeaderState();
}

class _WelcomeHeaderState extends State<_WelcomeHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Defer the entrance until the first frame so layout is settled,
    // and respect the user's reduce-motion preference if set.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1.0;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StaggeredEntry(
          controller: _controller,
          start: 0.00,
          end: 0.55,
          child: const _BrandMark(),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _StaggeredEntry(
          controller: _controller,
          start: 0.15,
          end: 0.75,
          child: Text('Ask Uganda', style: textTheme.displaySmall),
        ),
        const SizedBox(height: AppSpacing.sm),
        _StaggeredEntry(
          controller: _controller,
          start: 0.30,
          end: 0.85,
          child: Text(
            'A patient, multilingual assistant for every government service.',
            style: textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _StaggeredEntry(
          controller: _controller,
          start: 0.45,
          end: 1.00,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              'Ask in your own language. Get correct, personalised answers '
              'grounded in authoritative government registers through GUVA.',
              style: textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaggeredEntry extends StatelessWidget {
  const _StaggeredEntry({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, (1 - curved.value) * 12),
            child: child,
          ),
        );
      },
      child: child,
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
