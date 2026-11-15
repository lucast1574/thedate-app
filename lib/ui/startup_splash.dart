import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_config.dart';

/// The emblem and background match the native launch assets in both appearances.
/// Initialization owns the duration: no artificial delay or second intro scene.
class StartupSplash extends StatefulWidget {
  const StartupSplash({super.key, required this.onIntroComplete});
  final VoidCallback onIntroComplete;

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onIntroComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wedding = AppConfig.product == 'wedding';
    final dark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            // Match iOS and legacy Android geometry; Android 12+ sizes its own masked icon.
            Center(
              child: Semantics(
                label: 'Abriendo ${AppConfig.name}',
                image: true,
                child: SvgPicture.asset(
                  'assets/brand/splash-${dark ? 'dark' : 'light'}.svg',
                  width: 112,
                  height: 112,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            if (constraints.maxHeight >= 400)
              Positioned(
                top: constraints.maxHeight / 2 + 80,
                left: 32,
                right: 32,
                bottom: MediaQuery.paddingOf(context).bottom + 24,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text.rich(
                            TextSpan(
                              text: wedding ? 'SAVE THE DATE' : 'the date',
                              children: [
                                if (!wedding)
                                  const TextSpan(
                                    text: '.',
                                    style: TextStyle(color: Color(0xFFE45C87)),
                                  ),
                              ],
                            ),
                            semanticsLabel: AppConfig.name,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: AppConfig.headingFont,
                              fontSize: wedding ? 22 : 30,
                              fontWeight: wedding
                                  ? FontWeight.w600
                                  : FontWeight.w900,
                              letterSpacing: wedding ? 2.4 : -1,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          wedding
                              ? 'Cada detalle, con calma.'
                              : 'Que empiece la celebración.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
