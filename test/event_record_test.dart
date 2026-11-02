import 'dart:async';
import 'package:thedate_app/data/notification_gateway.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/domain/invitation_details.dart';
import 'package:thedate_app/state/app_model.dart';
import 'package:thedate_app/main.dart';
import 'fixtures.dart';

class PastRepository extends FakeRepository {
  @override
  Future<List<Celebration>> events() async => [
    Celebration(
      id: 'past',
      title: 'Mi evento',
      startsAt: DateTime.utc(2020, 1, 1),
      timeZone: 'America/Bogota',
      slug: 'mi-evento',
      publishedAt: DateTime.utc(2019),
    ),
  ];
}

class RecordNotifications implements NotificationGateway {
  final messages = StreamController<Map<String, dynamic>>.broadcast();
  @override
  Future<void> initialize() async {}
  @override
  Stream<Map<String, dynamic>> get opened => messages.stream;
  @override
  Stream<String> get registrations => const Stream.empty();
  @override
  Stream<void> get updates => const Stream.empty();
  @override
  String get platform => 'android';
  @override
  Future<bool> register({bool requestPermission = false}) async => false;
  @override
  Future<void> unregister() async {}
}

void main() {
  test(
    'old notifications select their record and preserve the requested destination',
    () async {
      final notifications = RecordNotifications();
      final model = AppModel(PastRepository(), notifications: notifications);
      await model.initialize();
      await Future<void>.delayed(Duration.zero);
      expect(model.event, isNull);
      notifications.messages.add({'eventId': 'past', 'screen': 'gifts'});
      for (var i = 0; i < 30 && model.event == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      expect(model.viewingRecord, true);
      expect(model.takeNotificationTab(), 1);
      await model.refresh();
      expect(model.event?.id, 'past');
      model.dispose();
      await notifications.messages.close();
    },
  );

  test('closure follows local midnight including DST and UTC fallback', () {
    for (final row in [
      ['America/Bogota', '2026-11-01T01:00:00Z', '2026-11-01T05:00:00Z'],
      ['America/New_York', '2026-11-01T05:30:00Z', '2026-11-02T05:00:00Z'],
      ['America/New_York', '2026-03-08T06:30:00Z', '2026-03-09T04:00:00Z'],
    ]) {
      final e = Celebration(
        id: 'past',
        title: 'Event',
        startsAt: DateTime.parse(row[1]),
        timeZone: row[0],
      );
      final end = DateTime.parse(row[2]);
      expect(
        eventEnded(e, end.subtract(const Duration(milliseconds: 1))),
        false,
      );
      expect(eventEnded(e, end), true);
      for (final product in ['general', 'wedding']) {
        final uri = privateInvitationUri(e, product, tab: 'tables');
        expect(uri.path, '/editor/past');
        expect(uri.queryParameters, {'tab': 'tables'});
        expect(
          uri.host,
          product == 'wedding' ? 'studio.save.thedate.now' : 'crea.thedate.now',
        );
      }
    }
  });
  testWidgets(
    'a single old event requires selection and keeps all three destinations',
    (tester) async {
      final model = AppModel(PastRepository());
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fonts = {
        'DM Sans': 'DMSans[opsz,wght].ttf',
        'Nunito': 'Nunito[wght].ttf',
      };
      for (final entry in fonts.entries) {
        await (FontLoader(
          entry.key,
        )..addFont(rootBundle.load('assets/fonts/${entry.value}'))).load();
      }
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: DateApp(model: model),
        ),
      );
      await tester.pumpAndSettle();
      expect(model.event, isNull);
      expect(find.text('Elegir evento'), findsOneWidget);
      await tester.tap(find.text('Elegir evento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mi evento'));
      await tester.pumpAndSettle();
      expect(model.viewingRecord, true);
      expect(find.text('Invitados'), findsOneWidget);
      await tester.runAsync(() async {
        final image =
            await (boundaryKey.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('artifacts').createSync(recursive: true);
        File(
          'artifacts/event-record-guests.png',
        ).writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      expect(find.text('Ver y descargar invitación'), findsOneWidget);
      await tester.tap(find.text('Regalos'));
      await tester.pumpAndSettle();
      expect(find.text('Consultar mesas'), findsOneWidget);
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      expect(find.text('Cerrar sesión'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
