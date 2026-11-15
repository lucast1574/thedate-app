import 'package:flutter/material.dart';
import 'widgets/brand.dart';

/// Finite entrance animation; startup work runs independently in AppModel.
class StartupSplash extends StatefulWidget {
  const StartupSplash({super.key, required this.onIntroComplete});
  final VoidCallback onIntroComplete;

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onIntroComplete();
          });
        }
      });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.duration = Duration.zero;
    }
    if (!controller.isAnimating && controller.value == 0) controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => Opacity(
              opacity: .65 + .35 * Curves.easeOut.transform(controller.value),
              child: child,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AccessArtwork(),
                  SizedBox(height: 24),
                  BrandWordmark(),
                  SizedBox(height: 12),
                  Text(
                    wedding
                        ? 'Cada detalle, con calma.'
                        : 'Tu celebración, más cerca.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
