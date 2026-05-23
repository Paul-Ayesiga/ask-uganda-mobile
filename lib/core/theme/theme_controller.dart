import 'package:flutter/material.dart';

class ThemeControllerScope extends InheritedWidget {
  const ThemeControllerScope({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required super.child,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  static ThemeControllerScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'ThemeControllerScope was not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ThemeControllerScope oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}
