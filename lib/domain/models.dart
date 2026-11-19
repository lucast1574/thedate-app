import '../l10n/translate.dart';
import 'message_models.dart';

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.email,
    this.googlePhotoUrl = '',
    this.avatarVersion = 0,
    this.role = '',
  });
  final String id, name, email;
  final String googlePhotoUrl;
  final int avatarVersion;
  final String role;
  factory Account.fromJson(Map<String, dynamic> j) => Account(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    email: j['email'] as String? ?? '',
    googlePhotoUrl: j['googlePhotoUrl'] as String? ?? '',
    avatarVersion: (j['avatarVersion'] as num?)?.toInt() ?? 0,
    role: j['role'] as String? ?? '',
  );
}

class Celebration {
  const Celebration({
    required this.id,
    required this.title,
    required this.startsAt,
    this.photoKey = '',
    this.slug = '',
    this.timeZone = '',
    this.publishedAt,
    this.ownerId = '',
    this.admission,
    this.maybeEnabled = true,
  });
  final String id, title;
  final DateTime? startsAt;
  final String photoKey, slug, timeZone;
  final DateTime? publishedAt;
  final String ownerId;
  final GuestAdmission? admission;
  final bool maybeEnabled;
  factory Celebration.fromJson(Map<String, dynamic> j) => Celebration(
    photoKey:
        (j['photoKeys'] as List? ?? []).whereType<String>().firstOrNull ?? '',
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    startsAt: DateTime.tryParse(j['startAt'] as String? ?? ''),
    slug: j['slug'] as String? ?? '',
    timeZone: j['timeZone'] as String? ?? '',
    publishedAt: DateTime.tryParse(j['publishedAt'] as String? ?? ''),
    ownerId: j['ownerId'] as String? ?? '',
    admission: GuestAdmission.fromJson(j['admission']),
    maybeEnabled: j['maybeEnabled'] != false,
  );
}

class Guest {
  const Guest({
    required this.id,
    required this.name,
    required this.response,
    required this.seats,
    required this.attendingSeats,
    this.companions = const [],
    this.respondedAt,
    this.phone = '',
    this.maybeReason = '',
    this.companionDetails = const [],
  });
  final String id, name, response;
  final int seats, attendingSeats;
  final List<String> companions;
  final DateTime? respondedAt;
  final String phone, maybeReason;
  final List<GuestCompanion> companionDetails;
  int get partySeats => attendingSeats > 0 ? attendingSeats : seats;
  bool get confirmed => response == 'going';
  bool get declined => response == 'not_going';
  bool get pending => !confirmed && !declined;
  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty && !['y', '&'].contains(s.toLowerCase()))
      .take(2)
      .map((s) => String.fromCharCode(s.runes.first))
      .join()
      .toUpperCase();
  factory Guest.fromJson(Map<String, dynamic> j) => Guest(
    id: j['id'] as String,
    name: [
      j['name'],
      j['lastName'],
    ].whereType<String>().where((s) => s.isNotEmpty).join(' '),
    response: j['response'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    maybeReason: j['maybeReason'] as String? ?? '',
    companionDetails: (j['companions'] as List? ?? [])
        .whereType<JsonMap>()
        .map(GuestCompanion.fromJson)
        .toList(),
    respondedAt: DateTime.tryParse(j['respondedAt'] as String? ?? ''),
    seats: (j['seats'] as num?)?.toInt() ?? 1,
    attendingSeats: (j['attendingSeats'] as num?)?.toInt() ?? 0,
    companions: (j['companions'] as List? ?? [])
        .map(
          (p) => p is Map
              ? [p['name'], p['lastName']].whereType<String>().join(' ')
              : '',
        )
        .where((s) => s.isNotEmpty)
        .toList(),
  );
}

class GuestCompanion {
  const GuestCompanion(this.name, this.lastName, [this.gender = 'unspecified']);

  final String name, lastName, gender;

  factory GuestCompanion.fromJson(JsonMap json) => GuestCompanion(
    json['name'] as String? ?? '',
    json['lastName'] as String? ?? '',
    json['gender'] as String? ?? 'unspecified',
  );

  JsonMap toJson() => {
    'name': name.trim(),
    'lastName': lastName.trim(),
    'gender': gender,
  };
}

class Gift {
  const Gift({
    required this.id,
    required this.title,
    required this.guestName,
    required this.delivered,
    this.reservedAt,
    this.imageUrl = '',
  });
  final String id, title, guestName;
  final String imageUrl;
  final bool delivered;
  final DateTime? reservedAt;
  bool get reserved => guestName.isNotEmpty;
  factory Gift.fromJson(Map<String, dynamic> j, Map<String, dynamic> names) =>
      Gift(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        imageUrl: j['imageUrl'] as String? ?? '',
        guestName: (j['guestId'] as String? ?? '').isEmpty
            ? ''
            : names[j['guestId']] as String? ?? tr("Invitado"),
        delivered: j['delivered'] == true,
        reservedAt: DateTime.tryParse(j['reservedAt'] as String? ?? ''),
      );
}

class Snapshot {
  const Snapshot(this.guests, this.gifts);
  final List<Guest> guests;
  final List<Gift> gifts;
  int get confirmedPeople => guests
      .where((g) => g.confirmed)
      .fold(
        0,
        (n, g) => n + (g.attendingSeats > 0 ? g.attendingSeats : g.seats),
      );
  int get pendingInvitations => guests.where((g) => g.pending).length;
}
