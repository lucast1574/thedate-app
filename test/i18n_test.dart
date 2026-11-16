import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/l10n/app_localizations.dart';
import 'package:thedate_app/l10n/translate.dart';
import 'package:thedate_app/state/app_model.dart';
import 'fixtures.dart';

void main() {
  test(
    'device preferences match regions and try every language before Spanish fallback',
    () {
      final supported = AppLocalizations.supportedLocales;
      expect(resolveAppLocale(null, supported), const Locale('es'));
      expect(
        resolveAppLocale(const [Locale('fr'), Locale('en', 'GB')], supported),
        const Locale('en'),
      );
      expect(
        resolveAppLocale(const [Locale('de'), Locale('pt', 'PT')], supported),
        const Locale('pt'),
      );
      expect(
        resolveAppLocale(const [Locale('ja'), Locale('fr')], supported),
        const Locale('es'),
      );
    },
  );

  test(
    'all ARB catalogs preserve placeholders and contain every translated message',
    () {
      final es =
          jsonDecode(File('lib/l10n/app_es.arb').readAsStringSync())
              as Map<String, dynamic>;
      final keys = es.keys.where((key) => !key.startsWith('@')).toSet();
      for (final locale in ['en', 'pt']) {
        final catalog =
            jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
                as Map<String, dynamic>;
        expect(catalog.keys.where((key) => !key.startsWith('@')).toSet(), keys);
        for (final key in keys) {
          expect((catalog[key] as String).trim(), isNotEmpty);
          final pattern = RegExp(r'\{v\d+\}');
          expect(
            pattern.allMatches(catalog[key] as String).map((m) => m[0]).toList()
              ..sort(),
            pattern.allMatches(es[key] as String).map((m) => m[0]).toList()
              ..sort(),
          );
        }
      }
    },
  );

  for (final entry in [
    (const [Locale('es', 'CO')], 'Continuar con Google'),
    (const [Locale('en', 'US')], 'Continue with Google'),
    (const [Locale('fr'), Locale('pt', 'BR')], 'Continuar com o Google'),
    (const [Locale('ja')], 'Continuar con Google'),
  ]) {
    testWidgets(
      'login automatically follows ${entry.$1} without overflow or selectors',
      (tester) async {
        tester.binding.platformDispatcher.localesTestValue = entry.$1;
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = FakeRepository()..signedIn = false;
        await tester.pumpWidget(DateApp(model: AppModel(repository)));
        await tester.pumpAndSettle();
        expect(find.text(entry.$2), findsOneWidget);
        expect(find.byType(DropdownButton<String>), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'a device language change rebuilds the app and retains typed input',
    (tester) async {
      tester.binding.platformDispatcher.localesTestValue = const [
        Locale('pt', 'PT'),
      ];
      final repository = FakeRepository()..signedIn = false;
      await tester.pumpWidget(DateApp(model: AppModel(repository)));
      await tester.pumpAndSettle();
      expect(find.text('Continuar com o Google'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'lucas@example.com',
      );
      tester.binding.platformDispatcher.localesTestValue = const [
        Locale('en', 'GB'),
      ];
      tester.binding.handleLocaleChanged();
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('lucas@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final locale in ['en', 'pt']) {
    testWidgets(
      'signed-in $locale preserves customer content and updates the navigation',
      (tester) async {
        tester.binding.platformDispatcher.localesTestValue = [Locale(locale)];
        await tester.pumpWidget(DateApp(model: AppModel(FakeRepository())));
        await tester.pumpAndSettle();
        expect(find.text('Valeria Mendoza'), findsOneWidget);
        expect(
          find.text(locale == 'en' ? 'Gifts' : 'Presentes'),
          findsOneWidget,
        );
        expect(
          tr('Foto de perfil de {v0}', {'v0': 'Nombre & Cuenta'}),
          contains('Nombre & Cuenta'),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
