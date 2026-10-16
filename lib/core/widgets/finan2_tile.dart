import 'package:flutter/material.dart';

import '../theme/finan2_tone.dart';

/// The redesign's `.tile`: an icon on its tone's soft tint, in a rounded
/// square - a category, a payment, a contribution.
class Finan2Tile extends StatelessWidget {
  const Finan2Tile({required this.icon, required this.tone, this.size = 36, super.key});

  final IconData icon;
  final Finan2Tone tone;

  /// 36 in a row; 32 for the small `.tile.sm` of a budget line.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: tone.tint, borderRadius: BorderRadius.circular(size / 3)),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.53, color: tone.color),
    );
  }
}
