import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'finan2_bars_icon.dart';

/// The gradient logo tile with the Finan2 bars mark, matching the mockup's
/// `.lg-logo`/`.logo` (used at the top of login/signup and the header).
class Finan2LogoTile extends StatelessWidget {
  const Finan2LogoTile({
    this.tileSize = 52,
    this.iconSize = 28,
    this.alignLeft = true,
    super.key,
  });

  final double tileSize;
  final double iconSize;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).colorScheme.primary;
    final brandDeep = Theme.of(context).extension<Finan2Colors>()!.brandDeep;
    final tile = Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brand, brandDeep],
        ),
        borderRadius: BorderRadius.circular(tileSize * 0.29),
      ),
      alignment: Alignment.center,
      child: Finan2BarsIcon(size: iconSize),
    );
    if (!alignLeft) return tile;
    return Align(alignment: Alignment.centerLeft, child: tile);
  }
}
