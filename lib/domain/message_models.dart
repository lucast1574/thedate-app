typedef JsonMap = Map<String, dynamic>;

class MessageAttachment {
  const MessageAttachment(this.mime, this.filename, this.available);

  final String mime, filename;
  final bool available;

  factory MessageAttachment.fromJson(JsonMap json) => MessageAttachment(
    json['mime'] as String? ?? '',
    json['filename'] as String? ?? '',
    json['available'] == true,
  );

  bool get image => mime.startsWith('image/');
  bool get pdf => mime == 'application/pdf';
  bool get video => mime.startsWith('video/');
  bool get audio => mime.startsWith('audio/') || mime == 'application/ogg';
  bool get receipt => image || pdf;
}

class GuestMessage {
  const GuestMessage({
    required this.id,
    required this.text,
    required this.incoming,
    required this.delivery,
    this.createdAt,
    this.media,
    this.automated = false,
    this.receiptReview,
    this.paymentRecorded = false,
  });

  final String id, text, delivery;
  final bool incoming, automated, paymentRecorded;
  final DateTime? createdAt;
  final MessageAttachment? media;
  final String? receiptReview;

  factory GuestMessage.fromJson(JsonMap json) => GuestMessage(
    id: json['id'] as String,
    text: json['text'] as String? ?? '',
    incoming: json['direction'] == 'in',
    delivery: json['delivery'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    media: switch (json['media']) {
      final JsonMap media => MessageAttachment.fromJson(media),
      _ => null,
    },
    automated: json['automation'] != null,
    receiptReview: json['receiptReview'] as String?,
    paymentRecorded: json['paymentRecorded'] == true,
  );
}

class GuestConversation {
  const GuestConversation(this.guestId, this.last, this.unread, this.pending);

  final String guestId;
  final GuestMessage last;
  final bool unread, pending;

  factory GuestConversation.fromJson(JsonMap json) => GuestConversation(
    json['guestId'] as String,
    GuestMessage.fromJson(json['last'] as JsonMap),
    json['unread'] == true,
    json['pending'] == true,
  );
}

class MessagePage {
  const MessagePage(this.messages, this.hasMore);
  final List<GuestMessage> messages;
  final bool hasMore;

  factory MessagePage.fromJson(JsonMap json) => MessagePage(
    (json['messages'] as List)
        .map((value) => GuestMessage.fromJson(value as JsonMap))
        .toList(),
    json['hasMore'] == true,
  );
}

class GuestAdmission {
  const GuestAdmission(this.currency, this.amountCents, this.perPerson);

  final String currency;
  final int amountCents;
  final bool perPerson;

  static GuestAdmission? fromJson(Object? value) {
    if (value is! JsonMap ||
        value['enabled'] != true ||
        value['currency'] is! String ||
        value['amountCents'] is! int) {
      return null;
    }
    return GuestAdmission(
      value['currency'] as String,
      value['amountCents'] as int,
      value['basis'] == 'person',
    );
  }

  int total(int seats) => amountCents * (perPerson && seats > 0 ? seats : 1);
}

class GuestPayment {
  const GuestPayment(
    this.guestId,
    this.amountCents,
    this.method,
    this.paidOn,
    this.createdAt,
    this.messageId,
    this.reference,
  );

  final String guestId, method, paidOn, createdAt, messageId, reference;
  final int amountCents;

  factory GuestPayment.fromJson(JsonMap json) => GuestPayment(
    json['guestId'] as String,
    json['amountCents'] as int,
    json['method'] as String,
    json['paidOn'] as String,
    json['createdAt'] as String,
    json['messageId'] as String? ?? '',
    json['reference'] as String? ?? '',
  );
}
