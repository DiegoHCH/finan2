import 'package:flutter/material.dart';

/// The Finan2 brand mark: 4 ascending stroked bars, traced from the mockup's
/// `#fbars`/`.logo svg` path (`M4 18V8m5 10V5m5 13v-7m5 7V9`), used inside the
/// gradient logo tile and the splash screen.
class Finan2BarsIcon extends StatelessWidget {
  const Finan2BarsIcon({this.size = 26, this.color = Colors.white, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BarsPainter(color)),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.color);

  final Color color;

  static const _bars = [
    [Offset(4, 18), Offset(4, 8)],
    [Offset(9, 18), Offset(9, 5)],
    [Offset(14, 18), Offset(14, 11)],
    [Offset(19, 18), Offset(19, 9)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final bar in _bars) {
      canvas.drawLine(bar[0] * scale, bar[1] * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) =>
      oldDelegate.color != color;
}
