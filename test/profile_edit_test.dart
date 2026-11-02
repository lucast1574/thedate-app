import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/app_config.dart';
import 'package:thedate_app/data/api_client.dart';
import 'package:thedate_app/data/events_repository.dart';
import 'package:thedate_app/data/profile_photo_picker.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/state/app_model.dart';
import 'fixtures.dart';

class EditRepository extends FakeRepository {
  Account current = account;
  int names = 0, photos = 0;
  bool photoFails = false;
  @override
  Future<Account> updateProfile(String name) async {
    names++;
    return current = Account(
      id: current.id,
      name: name,
      email: current.email,
      avatarVersion: current.avatarVersion,
    );
  }

  @override
  Future<Account> uploadAvatar(Uint8List photo) async {
    photos++;
    if (photoFails) throw const ApiException('No pudimos guardar la foto.');
    return current = Account(
      id: current.id,
      name: current.name,
      email: current.email,
      avatarVersion: 42,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'profile changes use the authenticated product API and multipart photo field',
    () async {
      var calls = 0;
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.headers['authorization'], 'Bearer profile-test-token');
          calls++;
          if (request.method == 'PATCH') {
            expect(request.url.toString(), '${AppConfig.api}/profile');
            expect(jsonDecode(request.body), {'name': 'Nuevo nombre'});
          } else {
            expect(request.method, 'POST');
            expect(request.url.toString(), '${AppConfig.api}/profile/avatar');
            expect(
              request.headers['content-type'],
              startsWith('multipart/form-data; boundary='),
            );
            expect(latin1.decode(request.bodyBytes), contains('name="photo"'));
          }
          return http.Response(
            jsonEncode({
              'id': 'profile',
              'name': 'Nuevo nombre',
              'email': 'profile@example.test',
              'avatarVersion': 42,
            }),
            200,
          );
        }),
      )..token = 'profile-test-token';
      final repo = EventsRepository(api: api);
      expect((await repo.updateProfile(' Nuevo nombre ')).name, 'Nuevo nombre');
      expect(
        (await repo.uploadAvatar(Uint8List.fromList([1, 2, 3]))).avatarVersion,
        42,
      );
      expect(calls, 2);
    },
  );
  test(
    'photo normalization produces a supported PNG within backend size and dimension limits',
    () async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 900, 700),
        Paint()..color = Colors.purple,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(900, 700);
      final raw = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      picture.dispose();
      final normalized = await ProfilePhotoPicker.normalize(
        raw!.buffer.asUint8List(),
      );
      expect(normalized.length, lessThanOrEqualTo(1 << 20));
      expect(normalized.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      final codec = await ui.instantiateImageCodec(normalized);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 480);
      expect(frame.image.height, lessThanOrEqualTo(480));
      frame.image.dispose();
      codec.dispose();
    },
  );
  test(
    'partial photo failure preserves saved name and retry does not resubmit it',
    () async {
      final repo = EditRepository()..photoFails = true;
      final model = AppModel(repo);
      await model.initialize();
      expect(
        await model.saveProfile('Nuevo nombre', photo: Uint8List(8)),
        isFalse,
      );
      expect(model.account!.name, 'Nuevo nombre');
      expect(model.error, isNotNull);
      repo.photoFails = false;
      expect(
        await model.saveProfile('Nuevo nombre', photo: Uint8List(8)),
        isTrue,
      );
      expect(repo.names, 1);
      expect(repo.photos, 2);
      expect(model.account!.avatarVersion, 42);
      model.dispose();
    },
  );
  testWidgets(
    'profile pencil opens minimal editor; back discards draft and save updates account',
    (tester) async {
      final repo = EditRepository();
      final model = AppModel(repo);
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cuenta'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Editar perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Cambiar foto'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Borrador');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(repo.names, 0);
      expect(model.account!.name, account.name);
      await tester.tap(find.byTooltip('Editar perfil'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Mi nombre visible');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar cambios'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();
      expect(repo.names, 1);
      expect(find.text('Mi nombre visible'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      model.dispose();
    },
  );
}
