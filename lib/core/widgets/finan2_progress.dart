import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The redesign's `.bar`: a thin track with the fill in [color], or in the
/// over color once [fraction] passes 1 - a budget that went over says so.
class Finan2ProgressBar extends StatelessWidget {
  const Finan2ProgressBar({
    required this.fraction,
    required this.color,
    this.height = 6,
    super.key,
  });

  final double fraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    final over = fraction > 1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colors.surfaceAlt),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0, 1).toDouble(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: over ? colors.expense : color,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The redesign's `.ring`: how much of a goal or debt is done at a glance,
/// with a short [label] (usually the percentage) in the middle.
class Finan2Ring extends StatelessWidget {
  const Finan2Ring({
    required this.fraction,
    required this.color,
    required this.label,
    this.size = 44,
    super.key,
  });

  final double fraction;
  final Color color;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<Finan2Colors>()!;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction.clamp(0, 1).toDouble(),
          color: color,
          track: colors.surfaceAlt,
          stroke: size * 0.115,
        ),
        child: Center(
          child: Text(
            label,
            style: Finan2Type.money.copyWith(
              fontSize: size * 0.24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              color: colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.color,
    required this.track,
    required this.stroke,
  });

  final double fraction;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        paint
          ..color = color
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track || old.stroke != stroke;
}
