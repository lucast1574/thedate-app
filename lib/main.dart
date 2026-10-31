import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/events_repository.dart';
import 'state/app_model.dart';
import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DateApp(model: AppModel(EventsRepository())));
}

class DateApp extends StatelessWidget {
  const DateApp({super.key, required this.model});
  final AppModel model;
  @override
  Widget build(BuildContext context) =>
      AppRoot(model: model, delegates: GlobalMaterialLocalizations.delegates);
}
