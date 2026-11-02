import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/app_config.dart';
import 'package:thedate_app/data/api_client.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/state/app_model.dart';
import 'package:thedate_app/ui/widgets/invitation_start.dart';
import 'fixtures.dart';

class EmptyRepository extends FakeRepository {
  List<Celebration> available = [];
  bool failed = false;
  @override
  Future<List<Celebration>> events() async {
    if (failed) throw const ApiException('Sin conexión');
    return available;
  }
}

class Browser extends UrlLauncherPlatform {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'empty accounts show branded guidance and launch only their product website externally',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.4;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final previous = UrlLauncherPlatform.instance, browser = Browser();
      UrlLauncherPlatform.instance = browser;
      addTearDown(() => UrlLauncherPlatform.instance = previous);
      final model = AppModel(EmptyRepository());
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      expect(find.byType(InvitationStart), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Continuar en la web'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar en la web'));
      await tester.pumpAndSettle();
      expect(browser.url, AppConfig.website);
      expect(browser.options?.mode, PreferredLaunchMode.externalApplication);
      expect(
        find.text('No pudimos abrir la web. Vuelve a intentarlo.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Regalos'));
      await tester.pumpAndSettle();
      expect(find.byType(InvitationStart), findsOneWidget);
      expect(
        find.text('Los regalos empiezan con tu invitación.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Confirmaciones'));
      await tester.pumpAndSettle();
      expect(find.text('Tu invitación empieza en la web.'), findsOneWidget);
      expect(
        find.text('Los regalos empiezan con tu invitación.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      model.dispose();
    },
  );
  testWidgets(
    'loading errors and existing invitations do not show the website start prompt',
    (tester) async {
      final repo = EmptyRepository()..failed = true;
      final model = AppModel(repo);
      await tester.pumpWidget(DateApp(model: model));
      await tester.pumpAndSettle();
      expect(find.byType(InvitationStart), findsNothing);
      expect(find.text('Sin conexión'), findsOneWidget);
      repo.failed = false;
      repo.available = [celebration];
      await model.refresh();
      await tester.pumpAndSettle();
      expect(find.byType(InvitationStart), findsNothing);
      expect(find.text('personas confirmadas'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      model.dispose();
    },
  );
}
