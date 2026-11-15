import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:thedate_app/app_config.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/state/app_model.dart';
import 'fixtures.dart';

class AccountBrowser extends UrlLauncherPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  String? url;
  LaunchOptions? options;
  bool fail = false;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    if (fail) throw Exception('Browser unavailable');
    this.url = url;
    this.options = options;
    return true;
  }
}

void main() {
  testWidgets(
    'three destinations show confirmations, reservations and account-only logout',
    (tester) async {
      final model = AppModel(FakeRepository());
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      expect(find.text('personas confirmadas'), findsOneWidget);
      expect(find.text('Valeria Mendoza'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsNothing);
      await tester.tap(find.text('Pendientes'));
      await tester.pumpAndSettle();
      expect(find.text('Mariana León'), findsOneWidget);
      expect(find.text('Valeria Mendoza'), findsNothing);
      await tester.tap(find.text('Regalos'));
      await tester.pumpAndSettle();
      expect(find.text('Cafetera para las mañanas juntos'), findsOneWidget);
      expect(find.text('Por Valeria Mendoza'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsNothing);
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      expect(find.text(account.email), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar sesión'));
      await tester.pumpAndSettle();
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('Valeria Mendoza'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'narrow phone and large text do not overflow any primary screen',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final model = AppModel(FakeRepository());
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Regalos'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'account links use the product web flow and deletion needs confirmation',
    (tester) async {
      final repo = FakeRepository();
      final model = AppModel(repo);
      final previous = UrlLauncherPlatform.instance;
      final browser = AccountBrowser();
      UrlLauncherPlatform.instance = browser;
      addTearDown(() => UrlLauncherPlatform.instance = previous);
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ayuda y soporte'));
      await tester.tap(find.text('Ayuda y soporte'));
      await tester.pumpAndSettle();
      expect(browser.url, AppConfig.supportUrl);
      expect(browser.options?.mode, PreferredLaunchMode.inAppBrowserView);
      await tester.ensureVisible(find.text('Eliminar cuenta'));
      await tester.tap(find.text('Eliminar cuenta'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Es permanente:'), findsOneWidget);
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();
      expect(browser.url, AppConfig.supportUrl);
      await tester.tap(find.text('Eliminar cuenta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar en la web'));
      await tester.pumpAndSettle();
      expect(browser.url, AppConfig.deletionUrl);
      expect(browser.options?.mode, PreferredLaunchMode.inAppBrowserView);
      expect(repo.deletionCalls, 0);
      expect(model.deletionRequested, isFalse);
      browser.fail = true;
      await tester.ensureVisible(find.text('Ayuda y soporte'));
      await tester.tap(find.text('Ayuda y soporte'));
      await tester.pumpAndSettle();
      expect(
        find.text('No pudimos abrir el enlace. Inténtalo de nuevo.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
