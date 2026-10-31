import 'dart:async';
import 'package:thedate_app/data/events_repository.dart';
import 'package:thedate_app/domain/models.dart';

const account = Account(
  id: 'review',
  name: 'Lucía y Mateo',
  email: 'cuenta-de-prueba@example.com',
);
final celebration = Celebration(
  id: 'celebration',
  title: 'Lucía y Mateo',
  startsAt: DateTime(2027, 6, 19),
);
const guestList = [
  Guest(
    id: 'a',
    name: 'Valeria Mendoza',
    response: 'going',
    seats: 2,
    attendingSeats: 2,
    companions: ['Diego Mendoza'],
  ),
  Guest(
    id: 'b',
    name: 'Camila Torres',
    response: 'going',
    seats: 1,
    attendingSeats: 1,
  ),
  Guest(
    id: 'c',
    name: 'Sofía Ramírez',
    response: 'going',
    seats: 1,
    attendingSeats: 1,
  ),
  Guest(
    id: 'd',
    name: 'Mariana León',
    response: '',
    seats: 2,
    attendingSeats: 0,
  ),
  Guest(
    id: 'e',
    name: 'Daniel Rojas',
    response: 'maybe',
    seats: 1,
    attendingSeats: 0,
  ),
  Guest(
    id: 'f',
    name: 'Ana Castro',
    response: 'not_going',
    seats: 1,
    attendingSeats: 0,
  ),
];
final sample = Snapshot(guestList, [
  Gift(
    id: 'a',
    title: 'Cafetera para las mañanas juntos',
    guestName: 'Valeria Mendoza',
    delivered: false,
    reservedAt: DateTime(2026, 10, 30),
  ),
  Gift(
    id: 'b',
    title: 'Un juego de copas',
    guestName: 'Camila Torres',
    delivered: false,
    reservedAt: DateTime(2026, 10, 29),
  ),
  Gift(
    id: 'c',
    title: 'Vajilla para compartir',
    guestName: 'Sofía Ramírez',
    delivered: true,
    reservedAt: DateTime(2026, 10, 28),
  ),
  const Gift(
    id: 'd',
    title: 'Un detalle para casa',
    guestName: '',
    delivered: false,
  ),
]);

class FakeRepository extends EventsRepository {
  bool signedIn = true;
  Snapshot snapshotValue = sample;
  Completer<Snapshot>? pending;
  bool fail = false;
  int deletionCalls = 0;
  String? submission;
  @override
  Future<Account?> restore() async => signedIn ? account : null;
  @override
  Future<Account> login(String email, String password) async {
    signedIn = true;
    return account;
  }

  @override
  Future<Account?> loginGoogle() async => null;
  @override
  Future<List<Celebration>> events() async => [celebration];
  @override
  Future<Snapshot> snapshot(String id) async {
    if (fail) throw StateError('network unavailable');
    return pending?.future ?? Future.value(snapshotValue);
  }

  @override
  Future<void> logout() async {
    signedIn = false;
  }

  @override
  String deletionId() => '00000000-0000-4000-8000-000000000001';
  @override
  Future<void> requestDeletion(String requestId) async {
    deletionCalls++;
    submission = requestId;
  }
}
