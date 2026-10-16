import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/finan2_tone.dart';

/// One block of the redesign's `.split`: a label in its tone's color over a
/// figure, on the tone's tint - what each person put in, or a year's totals.
class Finan2SplitBlock extends StatelessWidget {
  const Finan2SplitBlock({
    required this.tone,
    required this.label,
    required this.value,
    this.valueSize = 19,
    super.key,
  });

  final Finan2Tone tone;
  final String label;
  final String value;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(color: tone.tint, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: tone.color),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Finan2Type.money.copyWith(fontSize: valueSize, color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blocks side by side, 10 apart.
class Finan2Split extends StatelessWidget {
  const Finan2Split({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const SizedBox(width: Finan2Space.sm),
          Expanded(child: child),
        ],
      ],
    );
  }
}
