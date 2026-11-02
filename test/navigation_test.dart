import 'package:flutter/material.dart';
import 'package:thedate_app/ui/gifts.dart';
import 'package:thedate_app/ui/guests.dart';
import 'package:thedate_app/ui/account.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/state/app_model.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/ui/widgets/brand.dart';
import 'fixtures.dart';

class MultipleEvents extends FakeRepository {
  @override
  Future<List<Celebration>> events() async => [
    celebration,
    const Celebration(id: 'second', title: 'Mi cumpleaños', startsAt: null),
  ];
}

void main() {
  testWidgets(
    'rapid tab choices remain selected through background refresh and notification rebuilds',
    (tester) async {
      final model = AppModel(FakeRepository());
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.text('Regalos'));
        await tester.pump();
        expect(find.byType(GiftsScreen), findsOneWidget);
        await model.refresh();
        await tester.pump();
        expect(find.byType(GiftsScreen), findsOneWidget);
        await tester.tap(find.text('Confirmaciones'));
        await tester.pump();
        expect(find.byType(GuestsScreen), findsOneWidget);
      }
      model.notificationTab = 1;
      await model.refresh();
      await tester.pumpAndSettle();
      expect(find.byType(GiftsScreen), findsOneWidget);
      expect(model.notificationTab, isNull);
      await tester.tap(find.text('Cuenta'));
      await tester.pump();
      await model.refresh();
      await tester.pumpAndSettle();
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      model.dispose();
    },
  );

  testWidgets(
    'system back returns to confirmations and dismisses event sheet',
    (tester) async {
      final model = AppModel(MultipleEvents());
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Regalos'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('personas confirmadas'), findsOneWidget);
      await tester.tap(find.byType(EventPicker));
      await tester.pumpAndSettle();
      expect(find.text('Elegir evento'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Elegir evento'), findsNothing);
      await tester.tap(find.byType(EventPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mi cumpleaños'));
      await tester.pumpAndSettle();
      expect(model.event!.id, 'second');
      expect(find.text('Mi cumpleaños'), findsOneWidget);
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('personas confirmadas'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
  testWidgets('single event has no selectable dropdown', (tester) async {
    await tester.pumpWidget(DateApp(model: AppModel(FakeRepository())));
    await tester.pumpAndSettle();
    final tile = find.descendant(
      of: find.byType(EventPicker),
      matching: find.byType(ListTile),
    );
    expect(tester.widget<ListTile>(tile).onTap, isNull);
    expect(tester.widget<ListTile>(tile).trailing, isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
