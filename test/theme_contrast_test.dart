import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/ui/theme.dart';

double contrast(Color a, Color b) {
  final l1 = a.computeLuminance(), l2 = b.computeLuminance();
  return (l1 > l2 ? l1 + .05 : l2 + .05) / (l1 > l2 ? l2 + .05 : l1 + .05);
}

void main() {
  test(
    'native launch and Flutter share the requested neutral dark background',
    () {
      final theme = AppTheme.create(Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF181818));
      expect(theme.colorScheme.surfaceTint, Colors.transparent);
      expect(
        File(
          'android/app/src/main/res/values-night/launch_colors.xml',
        ).readAsStringSync(),
        contains('#181818'),
      );
      final catalog =
          jsonDecode(
                File(
                  'ios/Runner/Assets.xcassets/LaunchBackground.colorset/Contents.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final components =
          catalog['colors'][1]['color']['components'] as Map<String, dynamic>;
      for (final channel in ['red', 'green', 'blue']) {
        expect((double.parse(components[channel] as String) * 255).round(), 24);
      }
    },
  );
  for (final brightness in Brightness.values) {
    test('readable text and actions in $brightness', () {
      final theme = AppTheme.create(brightness);
      final scheme = theme.colorScheme;
      for (final surface in [
        scheme.surface,
        scheme.surfaceContainerLowest,
        scheme.surfaceContainerLow,
        scheme.surfaceContainer,
        scheme.surfaceContainerHigh,
        scheme.surfaceContainerHighest,
        scheme.primaryContainer,
      ]) {
        for (final ink in [
          scheme.onSurface,
          scheme.onSurfaceVariant,
          scheme.primary,
          scheme.error,
        ]) {
          expect(contrast(ink, surface), greaterThanOrEqualTo(4.5));
        }
      }
      expect(
        contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      final button = theme.filledButtonTheme.style!;
      expect(
        contrast(
          button.foregroundColor!.resolve({})!,
          button.backgroundColor!.resolve({})!,
        ),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
}
