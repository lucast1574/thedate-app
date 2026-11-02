// Local visual preview only. This entry point is never used by release builds.
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:thedate_app/main.dart';
import 'package:thedate_app/state/app_model.dart';
import 'preview_data.dart';

void main() {
  if (!kDebugMode) {
    throw StateError('Local preview is available only in debug builds.');
  }
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        message: 'DATOS DE EJEMPLO',
        location: BannerLocation.topEnd,
        child: DateApp(model: AppModel(PreviewRepository())),
      ),
    ),
  );
}
