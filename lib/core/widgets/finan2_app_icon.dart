import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'finan2_bars_icon.dart';

/// The full app icon mark: gradient squircle, white bars, gold "2" badge in
/// the corner — matches the mockup's `.appicon` (finan2-icono-splash.html).
/// Uses the fixed light-mode brand colors regardless of theme, since app
/// icons don't switch with in-app dark mode.
class Finan2AppIcon extends StatelessWidget {
  const Finan2AppIcon({this.size = 230, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final em = size;
    return SizedBox(
      width: em,
      height: em,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: em,
            height: em,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(em * 0.225),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Finan2Palette.brand, Finan2Palette.brandDeep],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(em * 0.225),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.44, -0.76),
                          radius: 0.9,
                          colors: [
                            Finan2Palette.onHero.withValues(alpha: 0.28),
                            Finan2Palette.onHero.withValues(alpha: 0),
                          ],
                          stops: const [0.0, 0.55],
                        ),
                      ),
                    ),
                  ),
                  Center(child: Finan2BarsIcon(size: em * 0.56)),
                ],
              ),
            ),
          ),
          Positioned(
            right: em * 0.12,
            bottom: em * 0.12,
            child: Container(
              width: em * 0.34,
              height: em * 0.34,
              decoration: BoxDecoration(
                color: Finan2Palette.logoAccent,
                borderRadius: BorderRadius.circular(em * 0.105),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: em * 0.12,
                    offset: Offset(0, em * 0.04),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '2',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Finan2Palette.onHero,
                  fontWeight: FontWeight.w800,
                  fontSize: em * 0.22,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
