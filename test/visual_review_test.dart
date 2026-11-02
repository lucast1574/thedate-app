import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/state/app_model.dart';
import '../integration_test/preview_data.dart';

void main() {
  testWidgets('visual inspection of four mobile screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    for (final entry in {
      'DM Sans': 'DMSans[opsz,wght].ttf',
      'Nunito': 'Nunito[wght].ttf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load('assets/fonts/${entry.value}'));
      await loader.load();
    }
    final model = AppModel(PreviewRepository());
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: DateApp(model: model),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      for (final asset in [
        'assets/brand/access-hero.png',
        'assets/preview/coffee.png',
        'assets/preview/glasses.png',
        'assets/preview/speaker.png',
        'assets/preview/vase.png',
      ]) {
        await precacheImage(
          asset.contains('/preview/')
              ? ResizeImage(AssetImage(asset), width: 240)
              : AssetImage(asset) as ImageProvider,
          tester.element(find.byType(MaterialApp)),
        );
      }
    });
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('artifacts/visual/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
      });
    }

    await capture('confirmations');
    await tester.tap(find.text('Regalos'));
    await tester.pumpAndSettle();
    await capture('gifts');
    await tester.tap(find.text('Cuenta'));
    await tester.pumpAndSettle();
    await capture('account');
    await model.logout();
    await tester.pumpAndSettle();
    await capture('login');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
