import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/state/app_model.dart';
import 'fixtures.dart';

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
    'deletion is a real request and can be cancelled before submission',
    (tester) async {
      final repo = FakeRepository();
      final used = AppModel(repo);
      await tester.pumpWidget(DateApp(model: used));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar eliminación de cuenta'));
      await tester.pumpAndSettle();
      expect(repo.deletionCalls, 0);
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();
      expect(repo.deletionCalls, 0);
      await tester.tap(find.text('Solicitar eliminación de cuenta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar solicitud'));
      await tester.pumpAndSettle();
      expect(repo.deletionCalls, 1);
      expect(used.deletionRequested, isTrue);
      await used.deleteAccount();
      expect(repo.deletionCalls, 1);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
