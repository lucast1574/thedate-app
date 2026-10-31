import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/state/app_model.dart';
import 'package:thedate_app/domain/models.dart';
import 'fixtures.dart';

void main() {
  test(
    'attendance counts actual people, pending and declined remain separate',
    () {
      expect(sample.confirmedPeople, 4);
      expect(sample.pendingInvitations, 2);
      expect(guestList.where((g) => g.declined).length, 1);
      expect(guestList.first.initials, 'VM');
    },
  );
  test(
    'a failed refresh retains the previous snapshot and last successful timestamp',
    () async {
      final repo = FakeRepository();
      final used = AppModel(repo);
      await used.initialize();
      final previous = used.updatedAt;
      repo.fail = true;
      await used.refresh();
      expect(used.data, same(sample));
      expect(used.updatedAt, previous);
      expect(used.error, isNotNull);
      used.dispose();
    },
  );
  test('a late snapshot cannot restore private data after logout', () async {
    final repo = FakeRepository();
    final used = AppModel(repo);
    await used.initialize();
    repo.pending = Completer<Snapshot>();
    final refresh = used.refresh();
    await Future<void>.delayed(Duration.zero);
    await used.logout();
    repo.pending!.complete(sample);
    await refresh;
    expect(used.account, isNull);
    expect(used.data, isNull);
    expect(used.event, isNull);
    used.dispose();
  });
}
