import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/data/notification_gateway.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/state/app_model.dart';
import 'fixtures.dart';

class Gateway implements NotificationGateway {
  final ids = StreamController<String>.broadcast();
  final taps = StreamController<Map<String, dynamic>>.broadcast();
  final changes = StreamController<void>.broadcast();
  int prompts = 0, unregisters = 0;
  @override
  String get platform => 'android';
  @override
  Stream<String> get registrations => ids.stream;
  @override
  Stream<Map<String, dynamic>> get opened => taps.stream;
  @override
  Stream<void> get updates => changes.stream;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> register({bool requestPermission = false}) async {
    if (requestPermission) prompts++;
    ids.add('installation-fid');
    return true;
  }

  @override
  Future<void> unregister() async {
    unregisters++;
  }

  Future<void> close() async {
    await ids.close();
    await taps.close();
    await changes.close();
  }
}

class ConnectedRepository extends FakeRepository {
  int registrations = 0, removals = 0, reads = 0;
  List<Celebration> available = [
    celebration,
    const Celebration(id: 'second', title: 'Otro evento', startsAt: null),
  ];
  @override
  Future<List<Celebration>> events() async => available;
  @override
  Future<Snapshot> snapshot(String id) async {
    reads++;
    return super.snapshot(id);
  }

  @override
  Future<void> registerDevice(String fid, String platform) async {
    registrations++;
  }

  @override
  Future<void> removeDevice() async {
    removals++;
  }
}

Future<void> settle() async {
  for (var i = 0; i < 12; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class PausedRepository extends ConnectedRepository {
  Completer<void>? pause;
  @override
  Future<List<Celebration>> events() async {
    await pause?.future;
    return super.events();
  }
}

void main() {
  test(
    'manual tab choice cancels a notification still loading its event',
    () async {
      final repo = PausedRepository(), gateway = Gateway();
      final model = AppModel(repo, notifications: gateway);
      await model.initialize();
      await settle();
      repo.pause = Completer<void>();
      gateway.taps.add({'eventId': 'second', 'screen': 'gifts'});
      await settle();
      expect(model.busy, isTrue);
      model.cancelNotificationNavigation();
      repo.pause!.complete();
      await settle();
      expect(model.notificationTab, isNull);
      expect(model.event!.id, celebration.id);
      model.dispose();
      await gateway.close();
    },
  );

  test(
    'push re-registers current session without prompting; logout removes both registrations',
    () async {
      final repo = ConnectedRepository(), gateway = Gateway();
      final model = AppModel(repo, notifications: gateway);
      await model.initialize();
      await settle();
      expect(repo.registrations, 1);
      expect(gateway.prompts, 0);
      await model.syncNotifications(requestPermission: true);
      await settle();
      expect(gateway.prompts, 1);
      await model.logout();
      expect(repo.removals, 1);
      expect(gateway.unregisters, 1);
      expect(model.data, isNull);
      gateway.ids.add('late-id');
      await settle();
      expect(repo.registrations, 2);
      model.dispose();
      await gateway.close();
    },
  );
  test(
    'a notification refreshes and opens only an accessible event; foreground keeps the current tab',
    () async {
      final repo = ConnectedRepository(), gateway = Gateway();
      final model = AppModel(repo, notifications: gateway);
      await model.initialize();
      await settle();
      gateway.taps.add({'eventId': 'second', 'screen': 'gifts'});
      await settle();
      expect(model.event?.id, 'second');
      expect(model.notificationTab, 1);
      gateway.taps.add({'eventId': 'foreign', 'screen': 'guests'});
      await settle();
      expect(model.event?.id, 'second');
      expect(model.notificationTab, 1);
      final before = repo.reads;
      gateway.changes.add(null);
      await settle();
      expect(repo.reads, greaterThan(before));
      expect(model.notificationTab, 1);
      model.dispose();
      await gateway.close();
    },
  );
  test(
    'removing access to the last event clears private data and timestamp',
    () async {
      final repo = ConnectedRepository();
      final model = AppModel(repo);
      await model.initialize();
      expect(model.data, isNotNull);
      repo.available = [];
      await model.refresh();
      expect(model.event, isNull);
      expect(model.data, isNull);
      expect(model.updatedAt, isNull);
      model.dispose();
    },
  );
}
