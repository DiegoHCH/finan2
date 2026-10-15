import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A household member avatar: colored circle with an initial, matching the
/// mockup's `.av`/`.miniav`/`.ob .ring .av` variants.
///
/// [memberIndex] picks the color: 0 -> `Finan2Colors.userA`, otherwise
/// `Finan2Colors.userB` (matches `.av.u1`/`.av.u2`).
class Finan2Avatar extends StatelessWidget {
  const Finan2Avatar({
    required this.label,
    required this.memberIndex,
    this.size = 30,
    this.borderWidth = 2,
    super.key,
  });

  final String label;
  final int memberIndex;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final background = memberIndex == 0 ? colors.userA : colors.userB;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: borderWidth > 0 ? Border.all(color: colors.surfaceAlt, width: borderWidth) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.4),
      ),
    );
  }
}
