// Design fixtures only. Never imported by lib/ or the release entry point.
import 'package:thedate_app/app_config.dart';
import 'package:thedate_app/data/events_repository.dart';
import 'package:thedate_app/domain/models.dart';

class PreviewRepository extends EventsRepository {
  bool signedIn = true;
  bool get wedding => AppConfig.product == 'wedding';
  Account get profile => Account(
    id: 'design-preview',
    name: wedding ? 'Ana & Mateo' : 'Valentina Ríos',
    email: wedding ? 'ana@ejemplo.com' : 'valentina@ejemplo.com',
  );
  @override
  Future<Account?> restore() async => signedIn ? profile : null;
  @override
  Future<Account> login(String email, String password) async {
    signedIn = true;
    return profile;
  }

  @override
  Future<Account?> loginGoogle() async => null;
  @override
  Future<void> logout() async {
    signedIn = false;
  }

  @override
  Future<List<Celebration>> events() async => [
    Celebration(
      id: 'design-primary',
      title: wedding ? 'Ana & Mateo' : 'Cumple de Valentina',
      startsAt: DateTime.utc(2027, 6, 19, 20),
      timeZone: 'America/Bogota',
      slug: 'design-preview',
      publishedAt: DateTime.utc(2026, 11, 1),
    ),
    Celebration(
      id: 'design-secondary',
      title: wedding ? 'Celebración íntima' : 'Cena con amigos',
      startsAt: DateTime(2027, 7, 3),
    ),
  ];
  @override
  Future<Snapshot> snapshot(String id) async {
    if (id == 'design-secondary') return const Snapshot([], []);
    final now = DateTime.now();
    final guests = [
      Guest(
        id: 'camila',
        name: 'Camila Torres',
        response: 'going',
        seats: 2,
        attendingSeats: 2,
        respondedAt: now.subtract(const Duration(minutes: 5)),
      ),
      Guest(
        id: 'diego',
        name: 'Diego Ramos',
        response: 'going',
        seats: 1,
        attendingSeats: 1,
        respondedAt: now.subtract(const Duration(minutes: 20)),
      ),
      Guest(
        id: 'lucia',
        name: 'Lucía y Mateo',
        response: 'going',
        seats: 2,
        attendingSeats: 2,
        respondedAt: now.subtract(const Duration(hours: 2)),
      ),
      Guest(
        id: 'andrea',
        name: 'Andrea Ruiz',
        response: 'going',
        seats: 1,
        attendingSeats: 1,
        respondedAt: now.subtract(const Duration(hours: 4)),
      ),
      for (var n = 0; n < 8; n++)
        Guest(
          id: 'pending-$n',
          name: 'Invitación pendiente ${n + 1}',
          response: '',
          seats: 2,
          attendingSeats: 0,
        ),
      for (var n = 0; n < 2; n++)
        Guest(
          id: 'declined-$n',
          name: 'Invitación ${n + 9}',
          response: 'not_going',
          seats: 1,
          attendingSeats: 0,
        ),
    ];
    final gifts = [
      Gift(
        id: 'coffee',
        title: 'Cafetera',
        guestName: 'Camila Torres',
        delivered: false,
        reservedAt: now,
        imageUrl: 'preview:assets/preview/coffee.png',
      ),
      Gift(
        id: 'second',
        title: wedding ? 'Set de copas' : 'Parlante',
        guestName: wedding ? 'Lucía y Mateo' : 'Diego Ramos',
        delivered: false,
        reservedAt: now.subtract(const Duration(minutes: 1)),
        imageUrl:
            'preview:assets/preview/${wedding ? 'glasses' : 'speaker'}.png',
      ),
      Gift(
        id: 'third',
        title: wedding ? 'Vasija de cerámica' : 'Set de copas',
        guestName: wedding ? 'Andrea Ruiz' : 'Lucía y Mateo',
        delivered: false,
        reservedAt: now.subtract(const Duration(minutes: 2)),
        imageUrl: 'preview:assets/preview/${wedding ? 'vase' : 'glasses'}.png',
      ),
      for (var n = 0; n < (wedding ? 9 : 5); n++)
        Gift(
          id: 'available-$n',
          title: [
            'Lámpara',
            'Ropa de cama',
            'Vajilla',
            'Jarrón',
            'Manta',
            'Tetera',
            'Toallas',
            'Cojines',
            'Cubiertos',
          ][n],
          guestName: '',
          delivered: false,
        ),
    ];
    return Snapshot(guests, gifts);
  }

  @override
  Future<void> requestDeletion(String requestId) async =>
      throw StateError('Esta es una vista previa local.');
}
