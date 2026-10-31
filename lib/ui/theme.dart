import 'package:flutter/material.dart';
import '../app_config.dart';

abstract final class AppTheme {
  static ThemeData create(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? AppConfig.ink : AppConfig.paper;
    final ink = dark ? AppConfig.paper : AppConfig.ink;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConfig.accent,
      brightness: brightness,
      primary: dark ? AppConfig.soft : AppConfig.accent,
      onPrimary: dark ? AppConfig.ink : AppConfig.paper,
      surface: surface,
      onSurface: ink,
      secondary: AppConfig.accent,
      surfaceContainerHighest: dark ? AppConfig.ink : AppConfig.soft,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'DM Sans',
      scaffoldBackgroundColor: surface,
      focusColor: AppConfig.soft.withValues(alpha: .3),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: TextStyle(
          fontFamily: AppConfig.headingFont,
          fontSize: 38,
          height: 1.08,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.1,
          color: ink,
        ),
        headlineMedium: TextStyle(
          fontFamily: AppConfig.headingFont,
          fontSize: 30,
          height: 1.1,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppConfig.soft,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: ink,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConfig.soft.withValues(alpha: dark ? 0.12 : 0.5),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: .08),
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
      ),
    );
  }
}
