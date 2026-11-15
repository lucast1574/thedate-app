import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_config.dart';

abstract final class AppTheme {
  static ThemeData create(Brightness brightness) {
    final wedding = AppConfig.product == 'wedding',
        dark = brightness == Brightness.dark;
    final ink = dark
        ? (wedding ? const Color(0xFFF4F0EA) : const Color(0xFFF2F2F2))
        : AppConfig.ink;
    final paper = dark ? const Color(0xFF181818) : AppConfig.paper;
    final raised = dark
        ? const Color(0xFF222222)
        : (wedding ? const Color(0xFFFAF6F0) : const Color(0xFFF7F3FD));
    final invitation = dark
        ? const Color(0xFF2C2C2C)
        : (wedding ? const Color(0xFFF3EEE6) : const Color(0xFFFFFAF1));
    final primary = dark
        ? (wedding ? const Color(0xFFDEB99B) : const Color(0xFFC8B6EA))
        : AppConfig.accent;
    final muted = dark
        ? (wedding ? const Color(0xFFC1BDB7) : const Color(0xFFBABABA))
        : (wedding ? const Color(0xFF6C6057) : const Color(0xFF625A70));
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppConfig.accent,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: dark ? paper : Colors.white,
          primaryContainer: invitation,
          onPrimaryContainer: ink,
          secondary: primary,
          onSecondary: dark ? paper : Colors.white,
          secondaryContainer: dark
              ? Color.alphaBlend(primary.withValues(alpha: .12), raised)
              : null,
          onSecondaryContainer: dark ? ink : null,
          error: dark ? const Color(0xFFFFABA6) : const Color(0xFFAE303B),
          onError: dark ? const Color(0xFF3C080E) : Colors.white,
          surface: paper,
          onSurface: ink,
          onSurfaceVariant: muted,
          surfaceContainerLowest: dark ? raised : Colors.white,
          surfaceContainerLow: dark ? const Color(0xFF262626) : raised,
          surfaceContainer: dark ? const Color(0xFF292929) : raised,
          surfaceContainerHigh: dark ? const Color(0xFF303030) : raised,
          surfaceContainerHighest: dark ? const Color(0xFF363636) : raised,
          surfaceDim: dark ? paper : null,
          surfaceBright: dark ? const Color(0xFF363636) : null,
          surfaceTint: dark ? Colors.transparent : null,
          outline: dark ? const Color(0xFF777777) : null,
          outlineVariant: dark
              ? const Color(0xFF383838)
              : ink.withValues(alpha: .10),
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
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      iconTheme: IconThemeData(color: muted),
      colorScheme: scheme,
      fontFamily: 'DM Sans',
      scaffoldBackgroundColor: paper,
      dividerColor: dark ? const Color(0xFF343434) : ink.withValues(alpha: .09),
      focusColor: primary.withValues(alpha: .14),
      hoverColor: primary.withValues(alpha: .08),
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
        centerTitle: wedding,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: paper,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
        ),
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: body(15, weight: FontWeight.w700, color: scheme.onPrimary),
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
        hintStyle: body(14, color: muted),
        labelStyle: body(14, color: muted),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        focusColor: scheme.primary.withValues(alpha: .12),
        errorBorder: border,
        focusedErrorBorder: border,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
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
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: heading(28),
        contentTextStyle: body(14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(wedding ? 12 : 24),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: raised,
        contentTextStyle: body(14),
        actionTextColor: primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        textColor: ink,
        selectedColor: scheme.primary,
        selectedTileColor: scheme.primary.withValues(alpha: .12),
      ),
    );
  }
}
