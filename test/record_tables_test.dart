import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thedate_app/data/api_client.dart';
import 'package:thedate_app/data/events_repository.dart';
import 'package:thedate_app/ui/record_tables.dart';
import 'fixtures.dart';

void main() {
  testWidgets('table records use authenticated GET and expose no editing', (
    tester,
  ) async {
    var calls = 0;
    final api = ApiClient(
      client: MockClient((request) async {
        calls++;
        expect(request.method, 'GET');
        expect(request.url.path.endsWith('/events/past/seating'), true);
        expect(request.headers['Authorization'], 'Bearer fixture');
        return http.Response(
          jsonEncode({
            'tables': [
              {'id': 't', 'name': 'Familia'},
            ],
            'assignments': {'a~0': 't'},
          }),
          200,
        );
      }),
    )..token = 'fixture';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordTables(
            eventId: 'past',
            repository: EventsRepository(api: api),
            data: sample,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Familia'), findsOneWidget);
    expect(find.textContaining('Valeria'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
    expect(calls, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
