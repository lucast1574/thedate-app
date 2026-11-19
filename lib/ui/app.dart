import '../l10n/app_localizations.dart';
import '../l10n/translate.dart';
import 'package:flutter/material.dart';
import '../app_config.dart';
import '../state/app_model.dart';
import 'theme.dart';
import 'login.dart';
import 'shell.dart';
import 'startup_splash.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.model, required this.delegates});
  final AppModel model;
  final Iterable<LocalizationsDelegate<dynamic>> delegates;
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  bool introComplete = false;
  final navigator = GlobalKey<NavigatorState>();
  String? accountId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.model.addListener(sessionChanged);
    widget.model.initialize();
  }

  void sessionChanged() {
    final next = widget.model.account?.id;
    if (accountId != null && accountId != next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) navigator.currentState?.popUntil((route) => route.isFirst);
      });
    }
    accountId = next;
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.model.removeListener(sessionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigator,
    title: AppConfig.name,
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.system,
    theme: AppTheme.create(Brightness.light),
    darkTheme: AppTheme.create(Brightness.dark),
    supportedLocales: AppLocalizations.supportedLocales,
    localeListResolutionCallback: resolveAppLocale,
    localizationsDelegates: [AppLocalizations.delegate, ...widget.delegates],
    home: ListenableBuilder(
      listenable: widget.model,
      builder: (context, _) => !introComplete || widget.model.starting
          ? StartupSplash(
              onIntroComplete: () {
                if (mounted && !introComplete) {
                  setState(() => introComplete = true);
                }
              },
            )
          : widget.model.account == null
          ? LoginScreen(model: widget.model)
          : AppShell(model: widget.model),
    ),
  );
}
