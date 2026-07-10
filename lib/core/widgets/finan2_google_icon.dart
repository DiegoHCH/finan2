import 'package:flutter/material.dart';

/// The official Google "G" mark (4-color), traced from the provided
/// `google.svg` (753×768 viewBox), used in the "Continuar con Google" button.
class Finan2GoogleIcon extends StatelessWidget {
  const Finan2GoogleIcon({this.size = 17, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 753, size.height / 768);

    final blue = Path()
      ..moveTo(752.64, 392.727)
      ..cubicTo(752.64, 365.498, 750.196, 339.316, 745.658, 314.182)
      ..lineTo(384, 314.182)
      ..lineTo(384, 462.895)
      ..lineTo(590.662, 462.895)
      ..cubicTo(581.585, 510.72, 554.356, 551.215, 513.513, 578.444)
      ..lineTo(513.513, 675.142)
      ..lineTo(638.138, 675.142)
      ..cubicTo(710.749, 608.116, 752.64, 509.673, 752.64, 392.727)
      ..close();

    final green = Path()
      ..moveTo(384, 768)
      ..cubicTo(487.68, 768, 574.604, 733.789, 638.138, 675.142)
      ..lineTo(513.513, 578.444)
      ..cubicTo(479.302, 601.484, 435.665, 615.447, 384, 615.447)
      ..cubicTo(284.16, 615.447, 199.331, 548.073, 168.96, 457.309)
      ..lineTo(41.1927, 457.309)
      ..lineTo(41.1927, 556.451)
      ..cubicTo(104.378, 681.775, 233.891, 768, 384, 768)
      ..close();

    final yellow = Path()
      ..moveTo(168.96, 456.96)
      ..cubicTo(161.28, 433.92, 156.742, 409.484, 156.742, 384)
      ..cubicTo(156.742, 358.516, 161.28, 334.08, 168.96, 311.04)
      ..lineTo(168.96, 211.898)
      ..lineTo(41.1927, 211.898)
      ..cubicTo(15.0109, 263.564, 0, 321.862, 0, 384)
      ..cubicTo(0, 446.138, 15.0109, 504.436, 41.1927, 556.102)
      ..lineTo(140.684, 478.604)
      ..lineTo(168.96, 456.96)
      ..close();

    final red = Path()
      ..moveTo(384, 152.902)
      ..cubicTo(440.553, 152.902, 490.822, 172.451, 530.967, 210.153)
      ..lineTo(640.931, 100.189)
      ..cubicTo(574.255, 38.0509, 487.68, 0, 384, 0)
      ..cubicTo(233.891, 0, 104.378, 86.2255, 41.1927, 211.898)
      ..lineTo(168.96, 311.04)
      ..cubicTo(199.331, 220.276, 284.16, 152.902, 384, 152.902)
      ..close();

    canvas.drawPath(blue, Paint()..color = _blue);
    canvas.drawPath(green, Paint()..color = _green);
    canvas.drawPath(yellow, Paint()..color = _yellow);
    canvas.drawPath(red, Paint()..color = _red);
  }

  @override
  bool shouldRepaint(covariant _GoogleGPainter oldDelegate) => false;
}
