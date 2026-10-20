import 'package:flutter/material.dart';

import '../theme/finan2_tone.dart';

/// The redesign's `.who`: a dot and a name in the member's color, for "who
/// paid" inside a row's sub-label. Colors are fixed per member (R5).
class Finan2PersonTag extends StatelessWidget {
  const Finan2PersonTag({required this.label, required this.memberIndex, super.key});

  final String label;
  final int memberIndex;

  @override
  Widget build(BuildContext context) {
    final tone = Finan2Tone.member(context, memberIndex);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: tone.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: tone.color),
        ),
      ],
    );
  }
}
