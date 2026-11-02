import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thedate_app/app_config.dart';
import 'package:thedate_app/data/api_client.dart';
import 'package:thedate_app/data/events_repository.dart';

void main() {
  test('gift images use the authorized API proxy', () async {
    final api = ApiClient(
      client: MockClient(
        (r) async => http.Response(
          jsonEncode(
            r.url.path.endsWith('/guests')
                ? []
                : {
                    'list': {
                      'items': [
                        {
                          'id': 'gift',
                          'title': 'Coffee',
                          'imageUrl': 'https://vendor.example/image.jpg',
                        },
                      ],
                    },
                    'guests': {},
                  },
          ),
          200,
        ),
      ),
    );
    final result = await EventsRepository(api: api).snapshot('event');
    expect(
      result.gifts.single.imageUrl,
      '${AppConfig.api}/events/event/wishlist/images/gift',
    );
  });

  test(
    'the repository only returns paid events of this product, excluding demos and other products',
    () async {
      final api = ApiClient(
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            '${AppConfig.api}/events?scope=organization',
          );
          expect(request.headers['Authorization'], 'Bearer private-session');
          return http.Response(
            jsonEncode([
              {
                'id': 'own',
                'title': 'Own event',
                'kind': AppConfig.product,
                'paymentStatus': 'paid',
              },
              {
                'id': 'other',
                'kind': AppConfig.product == 'general' ? 'wedding' : 'general',
                'paymentStatus': 'paid',
              },
              {
                'id': 'demo',
                'kind': AppConfig.product,
                'paymentStatus': 'paid',
                'isDemo': true,
              },
              {
                'id': 'unpaid',
                'kind': AppConfig.product,
                'paymentStatus': 'unpaid',
              },
            ]),
            200,
          );
        }),
      )..token = 'private-session';
      final events = await EventsRepository(api: api).events();
      expect(events.map((e) => e.id), ['own']);
    },
  );
  test(
    'reservation names come from authorized guest mapping, never a public fallback',
    () async {
      final api = ApiClient(
        client: MockClient(
          (request) async => http.Response(
            request.url.path.endsWith('/guests')
                ? jsonEncode([])
                : jsonEncode({
                    'list': {
                      'items': [
                        {
                          'id': 'reserved',
                          'title': 'A gift',
                          'guestId': 'guest',
                          'delivered': false,
                        },
                        {
                          'id': 'free',
                          'title': 'Another gift',
                          'delivered': false,
                        },
                      ],
                    },
                    'guests': {'guest': 'Nombre privado'},
                  }),
            200,
          ),
        ),
      );
      final snapshot = await EventsRepository(api: api).snapshot('own-event');
      expect(snapshot.gifts.first.guestName, 'Nombre privado');
      expect(snapshot.gifts.first.reserved, isTrue);
      expect(snapshot.gifts.last.reserved, isFalse);
    },
  );
  test(
    'session errors do not expose server response bodies or tokens',
    () async {
      final api = ApiClient(
        client: MockClient(
          (_) async => http.Response('{"error":"internal secret"}', 401),
        ),
      );
      await expectLater(
        api.request('/auth/me'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Tu sesión terminó. Vuelve a entrar.',
          ),
        ),
      );
    },
  );
}
