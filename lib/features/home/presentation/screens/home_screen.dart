import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/coat_of_arms_badge.dart';
import '../../../auth/presentation/screens/sign_in_screen.dart';

class _SessionActivityNotifier extends ChangeNotifier {
  void ping() {
    notifyListeners();
  }
}

class _SessionActivity {
  static final _SessionActivityNotifier notifier = _SessionActivityNotifier();

  static void ping() {
    notifier.ping();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _sessionTimeout = Duration(minutes: 2);

  int _selectedIndex = 0;
  Timer? _idleTimer;

  static const _pages = [
    _HomeOverviewPage(),
    _ConsentsPage(),
    _AlertsPage(),
    _ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _SessionActivity.notifier.addListener(_restartIdleTimer);
    _restartIdleTimer();
  }

  @override
  void dispose() {
    _SessionActivity.notifier.removeListener(_restartIdleTimer);
    _idleTimer?.cancel();
    super.dispose();
  }

  void _restartIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_sessionTimeout, _showSessionTimeout);
  }

  void _showSessionTimeout() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      _detailRoute(const _SessionTimeoutScreen()),
      (route) => false,
    );
  }

  void _selectTab(int index) {
    _restartIdleTimer();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _SessionActivity.ping(),
      onPointerMove: (_) => _SessionActivity.ping(),
      onPointerSignal: (_) => _SessionActivity.ping(),
      child: Scaffold(
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedIndex,
          onSelected: _selectTab,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.02, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _pages[_selectedIndex],
              ),
              const Positioned(
                top: 0,
                right: AppSpacing.lg,
                child: CoatOfArmsBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTimeoutScreen extends StatelessWidget {
  const _SessionTimeoutScreen();

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Session timed out',
      subtitle: 'GUVA locked this session after 2 minutes without activity.',
      icon: Icons.lock_clock_rounded,
      children: [
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign in again to continue reviewing consents and security activity.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    _detailRoute(const SignInScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign in again'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeOverviewPage extends StatelessWidget {
  const _HomeOverviewPage();

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      key: const ValueKey('home-overview'),
      title: 'Consent overview',
      subtitle:
          'Review who is requesting access to your verified identity data.',
      eyebrow: 'Good evening, Amina',
      children: const [
        _StatusPanel(),
        SizedBox(height: AppSpacing.lg),
        _NationalSymbolCard(),
        SizedBox(height: AppSpacing.lg),
        _PendingConsentCard(),
        SizedBox(height: AppSpacing.lg),
        _QuickActions(),
        SizedBox(height: AppSpacing.lg),
        _RecentActivity(),
      ],
    );
  }
}

class _ConsentsPage extends StatelessWidget {
  const _ConsentsPage();

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      key: const ValueKey('consents-page'),
      title: 'Consents',
      subtitle: 'Manage approved, pending, and declined data sharing requests.',
      eyebrow: '3 active records',
      children: [
        _ConsentStatusCard(
          title: 'NIRA verification desk',
          subtitle: 'National ID confirmation and date of birth',
          status: 'Pending',
          icon: Icons.pending_actions_outlined,
          onTap: () => _openDetail(
            context,
            const _ConsentDetailScreen(
              agency: 'NIRA verification desk',
              status: 'Pending',
              purpose: 'National ID confirmation and date of birth',
              requestedAt: 'Today at 20:48',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ConsentStatusCard(
          title: 'Centenary Bank',
          subtitle: 'Identity confirmation for account update',
          status: 'Allowed',
          icon: Icons.account_balance_outlined,
          onTap: () => _openDetail(
            context,
            const _ConsentDetailScreen(
              agency: 'Centenary Bank',
              status: 'Allowed',
              purpose: 'Identity confirmation for account update',
              requestedAt: 'Yesterday at 16:04',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ConsentStatusCard(
          title: 'Telecom SIM registration',
          subtitle: 'Subscriber identity recheck',
          status: 'Declined',
          icon: Icons.sim_card_outlined,
          onTap: () => _openDetail(
            context,
            const _ConsentDetailScreen(
              agency: 'Telecom SIM registration',
              status: 'Declined',
              purpose: 'Subscriber identity recheck',
              requestedAt: 'Monday at 09:18',
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertsPage extends StatelessWidget {
  const _AlertsPage();

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      key: const ValueKey('alerts-page'),
      title: 'Alerts',
      subtitle:
          'Security notices and verification activity that need attention.',
      eyebrow: '2 unread alerts',
      children: const [
        _NoticeCard(
          icon: Icons.warning_amber_rounded,
          title: 'New verification request',
          subtitle: 'NIRA verification desk requested access 12 minutes ago.',
        ),
        SizedBox(height: AppSpacing.md),
        _NoticeCard(
          icon: Icons.security_update_good_outlined,
          title: 'PIN changed successfully',
          subtitle: 'Your access PIN was updated yesterday at 19:12.',
        ),
        SizedBox(height: AppSpacing.md),
        _NoticeCard(
          icon: Icons.devices_outlined,
          title: 'Device signed in',
          subtitle: 'iPhone 17 Pro Max was used for your latest session.',
        ),
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      key: const ValueKey('profile-page'),
      title: 'Profile',
      subtitle: 'Your verified citizen access profile and account controls.',
      eyebrow: 'GUVA ID: GVA-2048-91',
      children: [
        const _ProfileSummary(),
        const SizedBox(height: AppSpacing.lg),
        const _ThemeModeCard(),
        const SizedBox(height: AppSpacing.lg),
        _ProfileAction(
          icon: Icons.password_rounded,
          label: 'Change Access PIN',
          onTap: () => _openDetail(context, const _ChangePinScreen()),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileAction(
          icon: Icons.fingerprint_rounded,
          label: 'Biometrics',
          onTap: () => _openDetail(context, const _BiometricsScreen()),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileAction(
          icon: Icons.devices_rounded,
          label: 'Trusted devices',
          onTap: () => _openDetail(context, const _TrustedDevicesScreen()),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileAction(
          icon: Icons.help_outline_rounded,
          label: 'Support',
          onTap: () => _openDetail(context, const _SupportScreen()),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileAction(
          icon: Icons.logout_rounded,
          label: 'Sign out',
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            _detailRoute(const SignInScreen()),
            (route) => false,
          ),
        ),
      ],
    );
  }
}

class _PageScroll extends StatelessWidget {
  const _PageScroll({
    super.key,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.children,
  });

  final String title;
  final String subtitle;
  final String eyebrow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              88,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eyebrow, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(title, style: textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(subtitle, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(children: children),
        ),
      ],
    );
  }
}

class _NationalSymbolCard extends StatelessWidget {
  const _NationalSymbolCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border.all(color: AppTheme.line(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/crested-crane.jpg', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.flagBlack.withValues(alpha: 0.76),
                  AppColors.flagBlack.withValues(alpha: 0.10),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 230),
                child: Text(
                  'Built for Uganda’s trusted citizen verification.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identity status',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Verified and protected',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingConsentCard extends StatelessWidget {
  const _PendingConsentCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.pending_actions_outlined,
            title: 'Pending request',
            actionLabel: 'Review',
            onAction: () => _openDetail(context, const _RequestReviewScreen()),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'NIRA verification desk',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Requests access to your National ID confirmation and date of birth.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openDetail(
                    context,
                    const _ConsentDecisionScreen(allowed: false),
                  ),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Decline'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openDetail(
                    context,
                    const _ConsentDecisionScreen(allowed: true),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Allow'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            onTap: () => _openDetail(context, const _ScanScreen()),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionTile(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: () => _openDetail(context, const _HistoryScreen()),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionTile(
            icon: Icons.security_rounded,
            label: 'Security',
            onTap: () => _openDetail(context, const _SecurityScreen()),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.line(context)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 82,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.receipt_long_outlined,
            title: 'Recent activity',
            actionLabel: 'All',
            onAction: () => _openDetail(context, const _HistoryScreen()),
          ),
          const SizedBox(height: AppSpacing.md),
          const _ActivityRow(
            title: 'Bank account verification',
            subtitle: 'Allowed today at 20:48',
            icon: Icons.account_balance_outlined,
          ),
          const Divider(height: AppSpacing.xl),
          const _ActivityRow(
            title: 'SIM registration check',
            subtitle: 'Declined yesterday',
            icon: Icons.sim_card_outlined,
          ),
        ],
      ),
    );
  }
}

class _ConsentStatusCard extends StatelessWidget {
  const _ConsentStatusCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TappableSurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            status,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: _ActivityRow(title: title, subtitle: subtitle, icon: icon),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          const _IconBox(icon: Icons.person_rounded),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amina Nakato',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'National ID: CM********1234',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard();

  @override
  Widget build(BuildContext context) {
    final controller = ThemeControllerScope.of(context);

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contrast_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
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
            selected: {controller.themeMode},
            onSelectionChanged: (selection) {
              controller.onThemeModeChanged(selection.first);
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TappableSurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(icon: icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.page(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
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

class _TappableSurfaceCard extends StatelessWidget {
  const _TappableSurfaceCard({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.line(context)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

class _RequestReviewScreen extends StatelessWidget {
  const _RequestReviewScreen();

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Review request',
      subtitle:
          'NIRA verification desk wants access to selected identity data.',
      icon: Icons.pending_actions_outlined,
      children: [
        const _DetailInfoCard(
          title: 'Requested records',
          rows: [
            ('National ID confirmation', 'Used to verify the ID is active'),
            ('Date of birth', 'Used for eligibility matching'),
            ('Full name', 'Used for official record matching'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openDetail(
                  context,
                  const _ConsentDecisionScreen(allowed: false),
                ),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Decline'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _openDetail(
                  context,
                  const _ConsentDecisionScreen(allowed: true),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Allow'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConsentDecisionScreen extends StatelessWidget {
  const _ConsentDecisionScreen({required this.allowed});

  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final title = allowed ? 'Consent allowed' : 'Consent declined';
    final subtitle = allowed
        ? 'NIRA verification desk can access the approved identity records for this request.'
        : 'NIRA verification desk will not receive access to your identity records.';

    return _DetailScaffold(
      title: title,
      subtitle: subtitle,
      icon: allowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
      children: [
        _SurfaceCard(
          child: Text(
            allowed
                ? 'This decision has been added to your consent history.'
                : 'The request remains visible in your history for audit purposes.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _ScanScreen extends StatelessWidget {
  const _ScanScreen();

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Scan verifier QR',
      subtitle: 'Scan a verifier code before sharing any identity details.',
      icon: Icons.qr_code_scanner_rounded,
      children: [
        Container(
          height: 240,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            border: Border.all(color: AppTheme.line(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.qr_code_2_rounded,
            size: 128,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Open camera'),
        ),
      ],
    );
  }
}

class _HistoryScreen extends StatelessWidget {
  const _HistoryScreen();

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Verification history',
      subtitle: 'Every consent and verification action stays visible to you.',
      icon: Icons.history_rounded,
      children: const [
        _ActivityRow(
          title: 'Bank account verification',
          subtitle: 'Allowed today at 20:48',
          icon: Icons.account_balance_outlined,
        ),
        Divider(height: AppSpacing.xl),
        _ActivityRow(
          title: 'SIM registration check',
          subtitle: 'Declined yesterday',
          icon: Icons.sim_card_outlined,
        ),
        Divider(height: AppSpacing.xl),
        _ActivityRow(
          title: 'NIRA profile lookup',
          subtitle: 'Reviewed on Monday',
          icon: Icons.badge_outlined,
        ),
      ],
    );
  }
}

class _SecurityScreen extends StatelessWidget {
  const _SecurityScreen();

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Security controls',
      subtitle: 'Manage the protections used for your GUVA account.',
      icon: Icons.security_rounded,
      children: [
        _ProfileAction(
          icon: Icons.password_rounded,
          label: 'Change Access PIN',
          onTap: () => _openDetail(context, const _ChangePinScreen()),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileAction(
          icon: Icons.fingerprint_rounded,
          label: 'Biometrics',
          onTap: () => _openDetail(context, const _BiometricsScreen()),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileAction(
          icon: Icons.devices_rounded,
          label: 'Trusted devices',
          onTap: () => _openDetail(context, const _TrustedDevicesScreen()),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileAction(
          icon: Icons.lock_clock_rounded,
          label: 'Session timeout',
          onTap: () => _openDetail(context, const _SessionPolicyScreen()),
        ),
      ],
    );
  }
}

class _ConsentDetailScreen extends StatelessWidget {
  const _ConsentDetailScreen({
    required this.agency,
    required this.status,
    required this.purpose,
    required this.requestedAt,
  });

  final String agency;
  final String status;
  final String purpose;
  final String requestedAt;

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Consent detail',
      subtitle: agency,
      icon: Icons.fact_check_rounded,
      children: [
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(agency, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(purpose, style: Theme.of(context).textTheme.bodyMedium),
              const Divider(height: AppSpacing.xl),
              _MetaRow(label: 'Status', value: status),
              const SizedBox(height: AppSpacing.md),
              _MetaRow(label: 'Requested', value: requestedAt),
              const SizedBox(height: AppSpacing.md),
              const _MetaRow(label: 'Expires', value: '29 days'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _DetailInfoCard(
          title: 'Shared records',
          rows: [
            ('National ID confirmation', 'Record validity only'),
            ('Full name', 'Official identity match'),
            ('Date of birth', 'Eligibility confirmation'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openDetail(
                  context,
                  const _ConsentDecisionScreen(allowed: false),
                ),
                icon: const Icon(Icons.block_rounded),
                label: const Text('Revoke'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Done'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrustedDevicesScreen extends StatelessWidget {
  const _TrustedDevicesScreen();

  @override
  Widget build(BuildContext context) {
    return const _DetailScaffold(
      title: 'Trusted devices',
      subtitle: 'Review devices that can access your GUVA account.',
      icon: Icons.devices_rounded,
      children: [
        _DeviceCard(
          name: 'iPhone 17 Pro Max',
          detail: 'This device · Last active now',
          trusted: true,
        ),
        SizedBox(height: AppSpacing.md),
        _DeviceCard(
          name: 'Chrome on macOS',
          detail: 'Last active yesterday at 19:12',
          trusted: true,
        ),
        SizedBox(height: AppSpacing.md),
        _DeviceCard(
          name: 'Unknown Android device',
          detail: 'Blocked 3 days ago near Kampala',
          trusted: false,
        ),
      ],
    );
  }
}

class _BiometricsScreen extends StatelessWidget {
  const _BiometricsScreen();

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Biometrics',
      subtitle: 'Use device biometrics for faster protected access.',
      icon: Icons.fingerprint_rounded,
      children: [
        const _DetailInfoCard(
          title: 'Enabled methods',
          rows: [
            ('Face ID', 'Available on this device'),
            ('Access PIN fallback', 'Required when biometrics are unavailable'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SurfaceCard(
          child: Row(
            children: [
              Icon(
                Icons.fingerprint_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Biometric unlock',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Switch(value: true, onChanged: (_) {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupportScreen extends StatelessWidget {
  const _SupportScreen();

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Support',
      subtitle: 'Get help with access, consents, or account security.',
      icon: Icons.help_outline_rounded,
      children: [
        const _DetailInfoCard(
          title: 'Contact channels',
          rows: [
            ('GUVA help desk', '+256 800 120 204'),
            ('Email support', 'support@guva.go.ug'),
            ('Service hours', 'Monday to Friday, 8:00 - 18:00'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: const Text('Start support chat'),
        ),
      ],
    );
  }
}

class _ChangePinScreen extends StatelessWidget {
  const _ChangePinScreen();

  @override
  Widget build(BuildContext context) {
    return _DetailScaffold(
      title: 'Change Access PIN',
      subtitle: 'Set a new numeric PIN for secure account access.',
      icon: Icons.password_rounded,
      children: [
        TextField(
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Current PIN',
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'New PIN',
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.check_rounded),
          label: const Text('Update PIN'),
        ),
      ],
    );
  }
}

class _SessionPolicyScreen extends StatelessWidget {
  const _SessionPolicyScreen();

  @override
  Widget build(BuildContext context) {
    return const _DetailScaffold(
      title: 'Session timeout',
      subtitle: 'GUVA locks authenticated sessions after idle time.',
      icon: Icons.lock_clock_rounded,
      children: [
        _DetailInfoCard(
          title: 'Current policy',
          rows: [
            ('Idle limit', '2 minutes'),
            ('Protected action', 'Sign in again after timeout'),
            ('Reason', 'Reduces risk on shared or unattended devices'),
          ],
        ),
      ],
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.name,
    required this.detail,
    required this.trusted,
  });

  final String name;
  final String detail;
  final bool trusted;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          _IconBox(
            icon: trusted ? Icons.phone_iphone_rounded : Icons.no_cell_rounded,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Icon(
            trusted ? Icons.verified_rounded : Icons.block_rounded,
            color: trusted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _SessionActivity.ping(),
      onPointerMove: (_) => _SessionActivity.ping(),
      onPointerSignal: (_) => _SessionActivity.ping(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        88,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            tooltip: 'Back',
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _IconBox(icon: icon),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    sliver: SliverList.list(children: children),
                  ),
                ],
              ),
              const Positioned(
                top: 0,
                right: AppSpacing.lg,
                child: CoatOfArmsBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          for (final row in rows) ...[
            _ActivityRow(
              title: row.$1,
              subtitle: row.$2,
              icon: Icons.check_circle_outline_rounded,
            ),
            if (row != rows.last) const Divider(height: AppSpacing.xl),
          ],
        ],
      ),
    );
  }
}

void _openDetail(BuildContext context, Widget screen) {
  Navigator.of(context).push(_detailRoute(screen));
}

PageRouteBuilder<void> _detailRoute(Widget screen) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.fact_check_outlined, Icons.fact_check_rounded, 'Consents'),
    (Icons.notifications_outlined, Icons.notifications_rounded, 'Alerts'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border(top: BorderSide(color: AppTheme.line(context))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _BottomNavItem(
                  icon: _items[index].$1,
                  activeIcon: _items[index].$2,
                  label: _items[index].$3,
                  selected: selectedIndex == index,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : AppTheme.muted(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? activeIcon : icon, color: color, size: 23),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontSize: 12,
                      height: 1.1,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: selected ? 46 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
