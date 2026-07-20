import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'finan2_app_icon.dart';

/// The live Flutter continuation of the native splash screen (see
/// flutter_native_splash.yaml and assets/splash/) - shown by AuthGate while
/// the initial auth/household state is loading, so there's no visual jump
/// between the static native splash and this screen taking over. Unlike the
/// native splash, this one can actually animate the loading dots.
class Finan2SplashScreen extends StatelessWidget {
  const Finan2SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saving = Theme.of(context).extension<Finan2Colors>()!.saving;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF1FB382), Finan2Palette.brandDeep]
                : const [Colors.white, Finan2Palette.groundLight],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Finan2AppIcon(size: 96),
                  const SizedBox(height: 22),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: Finan2Type.fontFamily,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : Finan2Palette.inkSoftLight,
                      ),
                      children: [
                        const TextSpan(text: 'Finan'),
                        TextSpan(text: '2', style: TextStyle(color: saving)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Finanzas del hogar - para dos',
                    style: TextStyle(
                      fontFamily: Finan2Type.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.84)
                          : Finan2Palette.inkFaintLight,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: _LoadingDots(color: isDark ? Colors.white : Finan2Palette.brand),
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

/// Three dots that pulse in sequence, like a typing indicator - the loop
/// keeps running for as long as this screen is on screen (auth/household
/// state loading), and simply disappears with the rest of the widget once
/// AuthGate swaps to the real content.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots({required this.color});

  final Color color;

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final phase = i * 0.18;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final wave = (math.sin(2 * math.pi * (_controller.value - phase)) + 1) / 2;
            final pulse = Curves.easeInOut.transform(wave);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: 0.35 + 0.65 * pulse,
                child: Transform.scale(
                  scale: 0.7 + 0.3 * pulse,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
