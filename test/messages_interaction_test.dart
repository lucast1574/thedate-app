import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thedate_app/app_config.dart';
import 'package:thedate_app/data/api_client.dart';
import 'package:thedate_app/data/events_repository.dart';
import 'package:thedate_app/domain/message_models.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/state/app_model.dart';
import 'package:thedate_app/ui/messages/conversation_screen.dart';
import 'package:thedate_app/ui/messages/message_input.dart';
import 'package:thedate_app/ui/widgets/bottom_tabs.dart';

class _InboxFixture extends EventsRepository {
  _InboxFixture() : super(api: ApiClient(client: MockClient(handle)));

  static final _image = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAIAAAAmkwkpAAAAE0lEQVR4nGP8//8/AwwwwVl4OQCWbgMF7ZjH1AAAAABJRU5ErkJggg==',
  );
  static Map<String, dynamic>? postedPayment;
  static const message = {
    'id': 'receipt',
    'direction': 'in',
    'text': 'Te envío el comprobante',
    'delivery': 'received',
    'createdAt': '2026-11-19T17:00:00Z',
    'media': {
      'mime': 'image/png',
      'filename': 'Comprobante.png',
      'available': true,
    },
    'receiptReview': 'possible',
  };

  static Future<http.Response> handle(http.Request request) async {
    final path = request.url.path;
    Object data = {'status': 'updated'};
    if (path.endsWith('/media')) {
      return http.Response.bytes(
        _image,
        200,
        headers: {'content-type': 'image/png'},
      );
    }
    if (path.endsWith('/guest-payments')) {
      if (request.method == 'POST') {
        postedPayment = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode(postedPayment), 201);
      }
      data = <Object>[];
    }
    if (path.endsWith('/conversations')) {
      data = [
        {'guestId': 'guest', 'last': message, 'unread': true, 'pending': true},
      ];
    }
    if (path.endsWith('/conversations/guest') && request.method == 'GET') {
      data = {
        'messages': [
          message,
          for (int index = 0; index < 30; index++)
            {
              ...message,
              'id': 'note-$index',
              'text': 'Mensaje anterior $index',
              'media': null,
            },
        ],
        'hasMore': false,
      };
    }
    return http.Response(
      jsonEncode(data),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  @override
  Future<Account?> restore() async =>
      const Account(id: 'owner', name: 'Lucía', email: 'owner@example.test');
  @override
  Future<List<Celebration>> events() async => [
    Celebration(
      id: 'event',
      title: 'Celebración de Lucía',
      ownerId: 'owner',
      startsAt: DateTime.now().add(const Duration(days: 4)),
      publishedAt: DateTime(2026, 11, 1),
      timeZone: 'America/Bogota',
      admission: const GuestAdmission('PEN', 8000, true),
    ),
  ];
  @override
  Future<Snapshot> snapshot(String id) async => const Snapshot([
    Guest(
      id: 'guest',
      name: 'Sofía Rivera',
      phone: '+51999998888',
      response: 'going',
      seats: 1,
      attendingSeats: 1,
    ),
  ], []);
}

void main() {
  Finder tab(String text) =>
      find.descendant(of: find.byType(BottomTabs), matching: find.text(text));
  Finder editable(Finder host) =>
      find.descendant(of: host, matching: find.byType(EditableText));
  final search = find.widgetWithText(
    MessageInput,
    'Buscar invitado o teléfono',
  );
  final draft = find.byKey(const Key('whatsapp-draft'));

  Future<void> setup(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final model = AppModel(_InboxFixture());
    await tester.pumpWidget(DateApp(model: model));
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(tab('Confirmaciones')).dx,
      lessThan(tester.getCenter(tab('Mensajes')).dx),
    );
    expect(
      tester.getCenter(tab('Regalos')).dx,
      lessThan(tester.getCenter(tab('Mensajes')).dx),
    );
    expect(
      tester.getCenter(tab('Mensajes')).dx,
      lessThan(tester.getCenter(tab('Cuenta')).dx),
    );
    await tester.tap(tab('Mensajes'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'touch dismisses the keyboard, and closing an attachment preserves draft and scroll',
    (tester) async {
      await setup(tester, width: 320);
      await tester.enterText(editable(search), '999998888');
      await tester.tapAt(const Offset(10, 90));
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isFalse);
      await tester.tap(editable(search));
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(editable(search)).focusNode.hasFocus,
        isFalse,
      );
      expect(find.text('Sofía Rivera'), findsOneWidget);
      await tester.tap(tab('Cuenta'));
      await tester.pumpAndSettle();
      await tester.tap(tab('Mensajes'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(editable(search)).controller.text,
        '999998888',
      );
      await tester.tap(find.text('Sofía Rivera'));
      await tester.pumpAndSettle();
      await tester.enterText(editable(draft), 'Te confirmo en unos minutos');
      tester.view.viewInsets = const FakeViewPadding(bottom: 290);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byTooltip('Enviar respuesta')).bottom,
        lessThanOrEqualTo(844 - 290),
      );
      await tester.tap(find.byTooltip('Ocultar teclado'));
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isFalse);
      await tester.tap(editable(draft));
      await tester.pumpAndSettle();
      final attachment = find.byKey(const ValueKey('attachment-receipt'));
      await tester.ensureVisible(attachment);
      final thread = find.descendant(
        of: find.byType(ConversationScreen),
        matching: find.byType(ListView),
      );
      final before = tester.widget<ListView>(thread).controller!.offset;
      await tester.tap(attachment);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.byKey(const Key('close-attachment')), findsOneWidget);
      await tester.pump();
      expect(find.text('No pudimos abrir el adjunto.'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.tap(find.byKey(const Key('close-attachment')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(editable(draft)).controller.text,
        'Te confirmo en unos minutos',
      );
      expect(tester.testTextInput.isVisible, isFalse);
      expect(
        tester.widget<ListView>(thread).controller!.offset,
        closeTo(before, 1),
      );
      await tester.tap(attachment);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(editable(draft)).controller.text,
        'Te confirmo en unos minutos',
      );
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );

  testWidgets(
    'payment tools are exposed only in The Date and preserve the receipt on save',
    (tester) async {
      _InboxFixture.postedPayment = null;
      await setup(tester);
      final enabled = AppConfig.product == 'general';
      expect(find.text('Pagos'), enabled ? findsOneWidget : findsNothing);
      await tester.tap(find.text('Sofía Rivera'));
      await tester.pumpAndSettle();
      final register = find.text('Registrar pago');
      expect(register, enabled ? findsOneWidget : findsNothing);
      if (enabled) {
        await tester.ensureVisible(register);
        await tester.tap(register);
        await tester.pumpAndSettle();
        final amount = find.widgetWithText(
          MessageInput,
          'Importe recibido · PEN',
        );
        await tester.enterText(editable(amount), '50,25');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver adjunto'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 450));
        await tester.tap(find.byKey(const Key('close-attachment')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<EditableText>(editable(amount)).controller.text,
          '50,25',
        );
        final verify = find.text('Verifiqué que recibí este importe.');
        await tester.ensureVisible(verify);
        await tester.tap(verify);
        await tester.pump();
        final save = find.text('Guardar pago');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(_InboxFixture.postedPayment?['messageId'], 'receipt');
        expect(_InboxFixture.postedPayment?['amountCents'], 5025);
        expect(_InboxFixture.postedPayment?['verified'], isTrue);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
}
