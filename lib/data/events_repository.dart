import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import '../app_config.dart';
import '../domain/models.dart';
import 'api_client.dart';
import 'google_identity.dart';

class EventsRepository {
  EventsRepository({
    ApiClient? api,
    FlutterSecureStorage? storage,
    GoogleIdentity? google,
  }) : api = api ?? ApiClient(),
       storage = storage ?? const FlutterSecureStorage(),
       google = google ?? GoogleIdentity();
  final ApiClient api;
  final FlutterSecureStorage storage;
  final GoogleIdentity google;
  final String _tokenKey = 'session-v1';
  Future<Account?> restore() async {
    api.token = await storage.read(key: _tokenKey);
    if (api.token == null) return null;
    try {
      return Account.fromJson(
        await api.request('/auth/me') as Map<String, dynamic>,
      );
    } on ApiException catch (e) {
      if (e.status == 401) {
        await logout();
        return null;
      }
      rethrow;
    }
  }

  Future<Account> login(String email, String password) async => _session(
    await api.request(
      '/auth/login',
      method: 'POST',
      body: {'email': email, 'password': password},
    ),
  );
  Future<Account?> loginGoogle() async {
    final token = await google.signIn();
    if (token == null) return null;
    return _session(
      await api.request(
        '/auth/google',
        method: 'POST',
        body: {'idToken': token, 'portal': AppConfig.product},
      ),
    );
  }

  Future<Account> _session(dynamic response) async {
    final token = response['token'] as String;
    await storage.write(key: _tokenKey, value: token);
    api.token = token;
    return Account.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<List<Celebration>> events() async {
    final list = await api.request('/events?scope=organization') as List;
    return list
        .where(
          (e) =>
              e['kind'] == AppConfig.product &&
              e['isDemo'] != true &&
              e['paymentStatus'] == 'paid',
        )
        .map((e) => Celebration.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort(
        (a, b) => (a.startsAt ?? DateTime(9999)).compareTo(
          b.startsAt ?? DateTime(9999),
        ),
      );
  }

  Future<Snapshot> snapshot(String id) async {
    final results = await Future.wait([
      api.request('/events/$id/guests'),
      api.request('/events/$id/wishlist'),
    ]);
    final guests = (results[0] as List)
        .map((j) => Guest.fromJson(j as Map<String, dynamic>))
        .toList();
    final gifts = results[1] as Map<String, dynamic>;
    final names = gifts['guests'] as Map<String, dynamic>? ?? {};
    final items =
        (gifts['list'] as Map<String, dynamic>?)?['items'] as List? ?? [];
    return Snapshot(
      guests,
      items
          .map(
            (j) => Gift.fromJson({
              ...j as Map<String, dynamic>,
              if ((j['imageUrl'] as String? ?? '').isNotEmpty)
                'imageUrl':
                    '${AppConfig.api}/events/${Uri.encodeComponent(id)}/wishlist/images/${Uri.encodeComponent(j['id'] as String)}',
            }, names),
          )
          .toList(),
    );
  }

  Future<Account> updateProfile(String name) async => Account.fromJson(
    await api.request('/profile', method: 'PATCH', body: {'name': name.trim()})
        as Map<String, dynamic>,
  );

  Future<Account> uploadAvatar(Uint8List photo) async =>
      Account.fromJson(await api.uploadPhoto(photo) as Map<String, dynamic>);

  Future<void> requestDeletion(String requestId) async {
    await api.request(
      '/support/tickets',
      method: 'POST',
      body: {
        'requestId': requestId,
        'title': 'Eliminar mi cuenta y datos de ${AppConfig.name}',
        'description':
            'Solicito la eliminación de mi cuenta y de los datos personales asociados en ${AppConfig.name}. Contactadme en el correo de esta cuenta para confirmar la titularidad y comunicar cualquier retención legal aplicable.',
        'images': <String>[],
      },
    );
  }

  String deletionId() => const Uuid().v4();
  Future<String> installationId() async {
    final existing = await storage.read(key: 'push-installation-v1');
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await storage.write(key: 'push-installation-v1', value: id);
    return id;
  }

  Future<void> registerDevice(String fid, String platform) async {
    await api.request(
      '/devices',
      method: 'POST',
      body: {
        'installationId': await installationId(),
        'fid': fid,
        'platform': platform,
      },
    );
  }

  Future<void> removeDevice() async {
    final id = await storage.read(key: 'push-installation-v1');
    if (id != null && api.token != null) {
      await api.request('/devices/$id', method: 'DELETE');
    }
  }

  Future<void> logout() async {
    await google.signOut();
    await storage.delete(key: _tokenKey);
    api.token = null;
  }
}
