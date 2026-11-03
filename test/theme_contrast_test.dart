import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/ui/theme.dart';

double contrast(Color a, Color b) {
  final l1 = a.computeLuminance(), l2 = b.computeLuminance();
  return (l1 > l2 ? l1 + .05 : l2 + .05) / (l1 > l2 ? l2 + .05 : l1 + .05);
}

void main() {
  for (final brightness in Brightness.values) {
    test('readable text and actions in $brightness', () {
      final theme = AppTheme.create(brightness);
      final scheme = theme.colorScheme;
      for (final surface in [scheme.surface, scheme.surfaceContainerLowest]) {
        for (final ink in [
          scheme.onSurface,
          scheme.onSurfaceVariant,
          scheme.primary,
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
