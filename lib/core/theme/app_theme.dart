import 'package:flutter/material.dart';

abstract final class AppColors {
  static const flagBlack = Color(0xFF111111);
  static const flagYellow = Color(0xFFFCD116);
  static const flagRed = Color(0xFFD21034);
  static const craneGrey = Color(0xFF8B928D);
  static const craneWhite = Color(0xFFFFFFFF);
  static const forest = flagBlack;
  static const leaf = Color(0xFFB3910E);
  static const gold = Color(0xFFC9A313);
  static const ink = Color(0xFF171717);
  static const muted = Color(0xFF6F756F);
  static const surface = Color(0xFFFBF8EF);
  static const line = Color(0xFFE7DEC5);
  static const danger = flagRed;
  static const darkSurface = Color(0xFF0E0E0D);
  static const darkCard = Color(0xFF181816);
  static const darkLine = Color(0xFF3D3727);
  static const darkMuted = Color(0xFFB9B3A3);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppTheme {
  static Color page(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color card(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color line(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  static Color muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.forest,
      secondary: AppColors.gold,
      tertiary: AppColors.flagRed,
      surface: Colors.white,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSecondary: AppColors.ink,
      onTertiary: Colors.white,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      outlineVariant: AppColors.line,
    );

    return _base(colorScheme, AppColors.surface);
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFFE0B84A),
      secondary: Color(0xFFFCD116),
      tertiary: Color(0xFFFF6B7C),
      surface: AppColors.darkCard,
      error: Color(0xFFFF8A99),
      onPrimary: Color(0xFF211A00),
      onSecondary: Color(0xFF2E2300),
      onTertiary: Color(0xFF37000B),
      onSurface: Color(0xFFF7F3E8),
      onSurfaceVariant: AppColors.darkMuted,
      outlineVariant: AppColors.darkLine,
    );

    return _base(colorScheme, AppColors.darkSurface);
  }

  static ThemeData _base(ColorScheme colorScheme, Color scaffoldBackground) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        displaySmall: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          height: 1.05,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
        border: _inputBorder(colorScheme.outlineVariant),
        enabledBorder: _inputBorder(colorScheme.outlineVariant),
        focusedBorder: _inputBorder(colorScheme.primary, width: 1.6),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
        ),
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.primary,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: width),
  );
}
