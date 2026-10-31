// Local visual preview only. This entry point is never used by release builds.
import 'package:flutter/material.dart';
import 'package:thedate_app/main.dart';
import 'package:thedate_app/state/app_model.dart';
import '../test/fixtures.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DateApp(model: AppModel(FakeRepository())));
}
