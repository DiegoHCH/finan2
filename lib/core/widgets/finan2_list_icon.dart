import 'package:flutter/material.dart';

/// The "Movimientos" nav icon: 3 horizontal strokes (the last one shorter),
/// traced from the mockup's path `M4 6h16M4 12h16M4 18h10`.
class Finan2ListIcon extends StatelessWidget {
  const Finan2ListIcon({this.size = 21, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Colors.black;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ListIconPainter(resolved)),
    );
  }
}

class _ListIconPainter extends CustomPainter {
  _ListIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(4, 6) * scale, Offset(20, 6) * scale, paint);
    canvas.drawLine(Offset(4, 12) * scale, Offset(20, 12) * scale, paint);
    canvas.drawLine(Offset(4, 18) * scale, Offset(14, 18) * scale, paint);
  }

  @override
  bool shouldRepaint(covariant _ListIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
