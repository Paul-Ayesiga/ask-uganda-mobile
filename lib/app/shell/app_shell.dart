import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _destinations = <_ShellDestination>[
    _ShellDestination(
      route: '/',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
      label: 'Assistant',
    ),
    _ShellDestination(
      route: '/services',
      icon: Icons.apps_outlined,
      activeIcon: Icons.apps_rounded,
      label: 'Services',
    ),
    _ShellDestination(
      route: '/life-events',
      icon: Icons.timeline_outlined,
      activeIcon: Icons.timeline_rounded,
      label: 'Life events',
    ),
    _ShellDestination(
      route: '/activity',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
      label: 'Activity',
    ),
  ];

  int get _selectedIndex {
    for (var i = _destinations.length - 1; i >= 0; i--) {
      if (location == _destinations[i].route ||
          location.startsWith('${_destinations[i].route}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex;
    return Scaffold(
      body: child,
      bottomNavigationBar: _ShellBottomNav(
        selectedIndex: selectedIndex,
        destinations: _destinations,
        onSelected: (index) {
          if (index == selectedIndex) return;
          context.go(_destinations[index].route);
        },
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _ShellBottomNav extends StatelessWidget {
  const _ShellBottomNav({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border(top: BorderSide(color: AppTheme.line(context))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _ShellItem(
                    destination: destinations[i],
                    selected: i == selectedIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellItem extends StatelessWidget {
  const _ShellItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : AppTheme.muted(context);
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
                  Icon(
                    selected ? destination.activeIcon : destination.icon,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontSize: 12,
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
                color: scheme.primary,
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
