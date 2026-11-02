import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/domain/models.dart';
import 'package:thedate_app/state/app_model.dart';
import 'package:thedate_app/ui/startup_splash.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('brand mark SVG compiles for native startup', () async {
    await const SvgAssetLoader('assets/brand/mark.svg').loadBytes(null);
  });
  testWidgets('session data loads while intro is visible', (tester) async {
    final repository = FakeRepository()..pending = Completer<Snapshot>();
    final model = AppModel(repository);
    await tester.pumpWidget(DateApp(model: model));
    await tester.pump();
    expect(find.byType(StartupSplash), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(model.starting, isTrue);
    repository.pending!.complete(sample);
    await tester.pumpAndSettle();
    expect(find.byType(StartupSplash), findsNothing);
    expect(find.text('personas confirmadas'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('reduced motion finishes without holding the user', (
    tester,
  ) async {
    var completed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StartupSplash(onIntroComplete: () => completed++),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(completed, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
