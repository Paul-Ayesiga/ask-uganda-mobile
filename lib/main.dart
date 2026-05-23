import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

void main() {
  runApp(const ProviderScope(child: AskUgandaApp()));
}

class AskUgandaApp extends ConsumerStatefulWidget {
  const AskUgandaApp({super.key});

  @override
  ConsumerState<AskUgandaApp> createState() => _AskUgandaAppState();
}

class _AskUgandaAppState extends ConsumerState<AskUgandaApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode themeMode) {
    setState(() => _themeMode = themeMode);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return ThemeControllerScope(
      themeMode: _themeMode,
      onThemeModeChanged: _setThemeMode,
      child: MaterialApp.router(
        title: 'Ask Uganda',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeMode,
        routerConfig: router,
      ),
    );
  }
}
