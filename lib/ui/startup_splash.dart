import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_config.dart';
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
        duration: const Duration(milliseconds: 1250),
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
    body: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            AppConfig.soft.withValues(alpha: .28),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final progress = Curves.easeOutCubic.transform(controller.value);
              return Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - progress)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: (wedding ? -.12 : -.22) * (1 - progress),
                        child: Transform.scale(
                          scale: .78 + .22 * progress,
                          child: Container(
                            width: 148,
                            height: 148,
                            decoration: BoxDecoration(
                              color: AppConfig.soft.withValues(alpha: .4),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(30),
                            child: SvgPicture.asset(
                              'assets/brand/mark.svg',
                              semanticsLabel: AppConfig.name,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60),
                        child: BrandWordmark(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        wedding
                            ? 'Cada detalle, con calma.'
                            : 'Tu celebración, más cerca.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 72,
                        child: LinearProgressIndicator(
                          value: controller.isCompleted ? null : progress,
                          minHeight: 2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
