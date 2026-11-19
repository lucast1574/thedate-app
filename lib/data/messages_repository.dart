import 'dart:typed_data';

import '../domain/message_models.dart';
import '../domain/models.dart';
import '../l10n/translate.dart';
import 'api_client.dart';

class MessagesRepository {
  const MessagesRepository(this.api, this.eventId);

  final ApiClient api;
  final String eventId;

  String get eventPath => '/events/${Uri.encodeComponent(eventId)}';
  String get inboxPath => '$eventPath/conversations';
  String threadPath(String guestId) =>
      '$inboxPath/${Uri.encodeComponent(guestId)}';

  Future<List<GuestConversation>> conversations() async =>
      (await api.request(inboxPath) as List)
          .map((value) => GuestConversation.fromJson(value as JsonMap))
          .toList();

  Future<MessagePage> history(String guestId, {String? before}) async {
    final query = before == null
        ? ''
        : '?before=${Uri.encodeComponent(before)}';
    return MessagePage.fromJson(
      await api.request('${threadPath(guestId)}$query') as JsonMap,
    );
  }

  Future<void> syncHistory(String guestId) async {
    await api.request('${threadPath(guestId)}/history', method: 'POST');
  }

  Future<void> mark(String guestId, String through, {bool? attended}) async {
    await api.request(
      threadPath(guestId),
      method: 'PATCH',
      body: {'through': through, 'attended': ?attended},
    );
  }

  Future<GuestMessage> send(
    String guestId,
    String id,
    String text,
    String? replyTo,
  ) async => GuestMessage.fromJson(
    await api.request(
          threadPath(guestId),
          method: 'POST',
          body: {'requestId': id, 'text': text, 'replyTo': ?replyTo},
        )
        as JsonMap,
  );

  Future<void> updateAttendance(
    String guestId,
    String response,
    String reason,
    List<GuestCompanion>? companions,
  ) async {
    if (companions != null &&
        companions.any((person) => person.name.trim().length < 2)) {
      throw ApiException(tr('Revisa el nombre de cada acompañante.'));
    }
    try {
      await api.request(
        '$eventPath/guests/${Uri.encodeComponent(guestId)}',
        method: 'PATCH',
        body: {
          'response': response,
          'reason': reason,
          if (companions != null)
            'companions': companions.map((person) => person.toJson()).toList(),
        },
      );
    } on ApiException catch (error) {
      if (error.status == 409) {
        throw ApiException(
          tr(
            'No se pudo guardar la asistencia. Revisa el aforo y el estado de la invitación.',
          ),
          409,
        );
      }
      rethrow;
    }
  }

  String mediaPath(String messageId) =>
      '$eventPath/messages/${Uri.encodeComponent(messageId)}/media';
  Future<Uint8List> media(String messageId) =>
      api.readPrivateMedia(mediaPath(messageId));

  Future<List<GuestPayment>> payments() async =>
      (await api.request('$eventPath/guest-payments') as List)
          .map((value) => GuestPayment.fromJson(value as JsonMap))
          .toList();

  Future<void> recordPayment(JsonMap payment) async {
    try {
      await api.request(
        '$eventPath/guest-payments',
        method: 'POST',
        body: payment,
      );
    } on ApiException catch (error) {
      if (error.status == 409) {
        throw ApiException(
          tr(
            'El comprobante ya está registrado o hubo cambios. Revisa los pagos antes de continuar.',
          ),
          409,
        );
      }
      rethrow;
    }
  }
}
