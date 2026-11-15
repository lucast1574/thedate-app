import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/state/app_model.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/ui/guests.dart';
import 'package:thedate_app/ui/widgets/common.dart';
import 'package:thedate_app/ui/widgets/app_icon.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'touch search can dismiss by outside tap, search action, drag and tab changes',
    (tester) async {
      final model = AppModel(FakeRepository());
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      final field = find.byType(TextField);
      Future<void> focusSearch() async {
        await tester.ensureVisible(field);
        await tester.tap(field);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .focusNode
              .hasFocus,
          isTrue,
        );
      }

      void expectDismissed() {
        final editable = tester.widget<EditableText>(find.byType(EditableText));
        expect(editable.focusNode.hasFocus, isFalse);
        expect(editable.controller.text, 'Valeria');
        expect(tester.testTextInput.isVisible, isFalse);
      }

      await focusSearch();
      await tester.enterText(field, 'Valeria');
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 90));
      await tester.pumpAndSettle();
      expectDismissed();
      expect(find.text('Valeria Mendoza'), findsOneWidget);

      await focusSearch();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expectDismissed();

      await focusSearch();
      await tester.drag(find.byType(ListView).first, const Offset(0, -100));
      await tester.pumpAndSettle();
      expectDismissed();

      await focusSearch();
      await tester.tap(find.text('Pendientes'));
      await tester.pumpAndSettle();
      expectDismissed();

      await focusSearch();
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(tester.testTextInput.isVisible, isFalse);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );

  for (final width in [320.0, 390.0]) {
    testWidgets('empty guest states share the screen center at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeRepository()
        ..snapshotValue = Snapshot([guestList.first], []);
      await tester.pumpWidget(DateApp(model: AppModel(repository)));
      await tester.pumpAndSettle();
      for (final item in {
        'Pendientes': 'Nadie queda pendiente',
        'No asistirán': 'Por ahora, ninguna ausencia',
      }.entries) {
        await tester.tap(find.text(item.key));
        await tester.pumpAndSettle();
        final center = tester.getCenter(find.byType(GuestsScreen)).dx;
        expect(tester.getCenter(find.text(item.value)).dx, closeTo(center, .5));
        expect(
          tester
              .getCenter(
                find.text('Cada respuesta se refleja automáticamente.'),
              )
              .dx,
          closeTo(center, .5),
        );
        final icon = find.descendant(
          of: find.byType(EmptyState),
          matching: find.byType(AppIcon),
        );
        expect(tester.getCenter(icon).dx, closeTo(center, .5));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
