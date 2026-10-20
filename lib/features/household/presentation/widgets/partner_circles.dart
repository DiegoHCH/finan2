import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/finan2_tone.dart';

/// The member's circle and, overlapping it, the partner's empty one with a
/// dashed edge: someone is still missing.
class PartnerCircles extends StatelessWidget {
  const PartnerCircles({
    required this.initial,
    required this.memberIndex,
    required this.missingLabel,
    this.size = 58,
    super.key,
  });

  /// The member's own initial.
  final String initial;

  /// The member's place in the household (their color); the partner gets
  /// the other one.
  final int memberIndex;

  /// What a screen reader says for the empty circle.
  final String missingLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final own = Finan2Tone.member(context, memberIndex);
    final partner = Finan2Tone.member(context, memberIndex == 0 ? 1 : 0);
    final textStyle = TextStyle(fontSize: size * 0.34, fontWeight: FontWeight.w800);
    const overlap = 12.0;
    return Center(
      child: SizedBox(
        width: size * 2 - overlap,
        height: size,
        child: Stack(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: own.tint, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(initial, style: textStyle.copyWith(color: own.color)),
            ),
            Positioned(
              left: size - overlap,
              child: Semantics(
                label: missingLabel,
                child: CustomPaint(
                  foregroundPainter: _DashedRing(color: partner.color),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(color: partner.tint, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: ExcludeSemantics(
                      child: Text('?', style: textStyle.copyWith(color: partner.color)),
                    ),
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

class _DashedRing extends CustomPainter {
  _DashedRing({required this.color});

  final Color color;

  static const _stroke = 3.0;
  static const _dashes = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.butt;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(_stroke / 2);
    const sweep = 2 * math.pi / _dashes;
    for (var i = 0; i < _dashes; i++) {
      canvas.drawArc(rect, i * sweep - math.pi / 2, sweep * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRing oldDelegate) => oldDelegate.color != color;
}
