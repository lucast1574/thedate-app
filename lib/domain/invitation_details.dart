import 'package:timezone/data/latest.dart' as database;
import 'package:timezone/timezone.dart' as tz;
import 'models.dart';

bool _zonesReady = false;

DateTime eventLocalTime(Celebration event, DateTime instant) {
  if (!_zonesReady) {
    database.initializeTimeZones();
    _zonesReady = true;
  }
  try {
    return tz.TZDateTime.from(instant, tz.getLocation(event.timeZone));
  } on tz.LocationNotFoundException {
    return instant.toLocal();
  }
}

String? eventCountdown(Celebration event, DateTime now) {
  if (event.startsAt == null) return null;
  final day = eventLocalTime(event, event.startsAt!);
  final today = eventLocalTime(event, now);
  // Compare calendar dates, avoiding daylight-saving days of 23 or 25 hours.
  final days = DateTime.utc(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
  if (days == 0) return '¡Hoy es el día!';
  if (days == 1) return 'Falta 1 día';
  if (days > 1) return 'Faltan $days días';
  return 'Celebración realizada';
}

Uri? generalInvitationUri(Celebration event, String product) {
  final slug = event.slug;
  const reserved = {
    'www',
    'api',
    'app',
    'admin',
    'backoffice',
    'crea',
    'studio',
    'save',
    'mail',
    'static',
    'assets',
    'support',
  };
  if (event.publishedAt == null ||
      !{'general', 'wedding'}.contains(product) ||
      !RegExp(r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$').hasMatch(slug) ||
      slug.contains('--') ||
      reserved.contains(slug)) {
    return null;
  }
  // Root URL only: never add a guest route, token, query or session.
  return Uri.https(
    '$slug.${product == 'wedding' ? 'save.' : ''}thedate.now',
    '/',
  );
}
