import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:thedate_app/app_config.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/domain/invitation_details.dart';
import 'package:thedate_app/ui/widgets/event_invitation_details.dart';

class InvitationBrowser extends UrlLauncherPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  String? url;
  LaunchOptions? options;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    this.url = url;
    this.options = options;
    return false;
  }
}

Celebration event({
  String slug = 'ana-y-mateo',
  bool published = true,
  String zone = 'America/Bogota',
  String date = '2027-06-20T02:00:00Z',
}) => Celebration.fromJson({
  'id': 'event',
  'title': 'Celebración',
  'slug': slug,
  'timeZone': zone,
  'startAt': date,
  'publishedAt': published ? '2026-11-01T12:00:00Z' : null,
});

void main() {
  test(
    'calendar countdown follows the event timezone and daylight-saving changes',
    () {
      final e = event();
      expect(eventLocalTime(e, e.startsAt!).day, 19);
      expect(
        eventCountdown(e, DateTime.parse('2027-06-19T04:59:00Z')),
        'Falta 1 día',
      );
      expect(
        eventCountdown(e, DateTime.parse('2027-06-19T05:00:00Z')),
        '¡Hoy es el día!',
      );
      expect(
        eventCountdown(e, DateTime.parse('2027-06-20T05:00:00Z')),
        'Celebración realizada',
      );
      final dst = event(zone: 'America/New_York', date: '2027-03-15T04:00:00Z');
      expect(
        eventCountdown(dst, DateTime.parse('2027-03-14T05:00:00Z')),
        'Falta 1 día',
      );
      expect(
        eventCountdown(e, DateTime.parse('2027-06-17T12:00:00Z')),
        'Faltan 2 días',
      );
      expect(
        eventCountdown(
          const Celebration(id: 'x', title: 'x', startsAt: null),
          DateTime.now(),
        ),
        isNull,
      );
      expect(
        eventLocalTime(event(zone: 'invalid'), DateTime.utc(2027)).isUtc,
        isFalse,
      );
    },
  );
  test(
    'general published invitation uses only its product host without guest identity',
    () {
      for (final product in ['general', 'wedding']) {
        final uri = generalInvitationUri(event(), product)!;
        expect(
          uri.toString(),
          'https://ana-y-mateo.${product == 'wedding' ? 'save.' : ''}thedate.now/',
        );
        expect(uri.query, isEmpty);
        expect(uri.userInfo, isEmpty);
        expect(uri.fragment, isEmpty);
      }
      expect(generalInvitationUri(event(published: false), 'general'), isNull);
      for (final slug in [
        'bad/path',
        'evil.com',
        'name?token=guest',
        'api',
        'a--b',
        '',
      ]) {
        expect(generalInvitationUri(event(slug: slug), 'general'), isNull);
      }
    },
  );
  testWidgets(
    'published action opens generic invitation externally and handles browser failure',
    (tester) async {
      final previous = UrlLauncherPlatform.instance,
          browser = InvitationBrowser();
      UrlLauncherPlatform.instance = browser;
      addTearDown(() => UrlLauncherPlatform.instance = previous);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EventInvitationDetails(event: event())),
        ),
      );
      await tester.tap(find.text('Ver mi invitación'));
      await tester.pumpAndSettle();
      expect(
        browser.url,
        generalInvitationUri(event(), AppConfig.product).toString(),
      );
      expect(browser.options?.mode, PreferredLaunchMode.externalApplication);
      expect(
        find.text('No pudimos abrir la invitación. Vuelve a intentarlo.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'unpublished invitation has no action and fits a narrow screen with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: EventInvitationDetails(event: event(published: false)),
            ),
          ),
        ),
      );
      expect(find.text('Invitación aún no publicada'), findsOneWidget);
      expect(find.text('Ver mi invitación'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
