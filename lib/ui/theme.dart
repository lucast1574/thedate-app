import 'package:flutter/material.dart';
import '../app_config.dart';

abstract final class AppTheme {
  static ThemeData create(Brightness brightness) {
    final wedding = AppConfig.product == 'wedding',
        dark = brightness == Brightness.dark;
    final ink = dark ? AppConfig.paper : AppConfig.ink;
    final paper = dark ? const Color(0xFF211B2B) : AppConfig.paper;
    final muted = dark
        ? const Color(0xFFC2B8CE)
        : (wedding ? const Color(0xFF79716C) : const Color(0xFF706883));
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppConfig.accent,
          brightness: brightness,
        ).copyWith(
          primary: dark ? AppConfig.soft : AppConfig.accent,
          onPrimary: Colors.white,
          surface: paper,
          onSurface: ink,
          onSurfaceVariant: muted,
          surfaceContainerLowest: dark ? const Color(0xFF2C2538) : Colors.white,
          outlineVariant: ink.withValues(alpha: .10),
        );
    TextStyle body(
      double size, {
      FontWeight weight = FontWeight.w400,
      Color? color,
    }) => TextStyle(
      fontFamily: 'DM Sans',
      fontSize: size,
      height: 1.3,
      letterSpacing: -.2,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color ?? ink,
    );
    TextStyle heading(double size) => TextStyle(
      fontFamily: AppConfig.headingFont,
      fontSize: size,
      height: 1.07,
      letterSpacing: wedding ? -1 : -.8,
      fontWeight: wedding ? FontWeight.w500 : FontWeight.w900,
      fontVariations: [FontVariation('wght', wedding ? 500 : 900)],
      color: ink,
    );
    final radius = BorderRadius.circular(wedding ? 5 : 14);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: ink.withValues(alpha: .10)),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'DM Sans',
      scaffoldBackgroundColor: paper,
      dividerColor: ink.withValues(alpha: .09),
      focusColor: AppConfig.soft.withValues(alpha: .45),
      hoverColor: AppConfig.soft.withValues(alpha: .2),
      textTheme: TextTheme(
        headlineLarge: heading(wedding ? 36 : 32),
        headlineMedium: heading(wedding ? 34 : 30),
        titleLarge: body(18, weight: FontWeight.w700),
        titleMedium: body(15, weight: FontWeight.w700),
        bodyLarge: body(16, color: muted),
        bodyMedium: body(14),
        bodySmall: body(12, color: muted),
        labelLarge: body(14, weight: FontWeight.w600),
        labelMedium: body(12, color: muted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          backgroundColor: AppConfig.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: body(15, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: body(13, weight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: dark
            ? scheme.surfaceContainerLowest
            : (wedding
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: .85)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: body(13, color: muted.withValues(alpha: .8)),
        labelStyle: body(13, color: muted),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: ink.withValues(alpha: .2)),
        ),
        errorBorder: border,
      ),
      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: .10),
        space: 1,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(wedding ? 12 : 24),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        textColor: ink,
        selectedColor: AppConfig.accent,
        selectedTileColor: AppConfig.soft.withValues(alpha: .4),
      ),
    );
  }
}
