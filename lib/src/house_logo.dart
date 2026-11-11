import 'package:flutter/material.dart';

class HouseLogo extends StatelessWidget {
  const HouseLogo({this.size = 48, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Houses logo',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _HousePainter(
            color: dark ? const Color(0xFFF2B544) : const Color(0xFFE59E12),
          ),
        ),
      ),
    );
  }
}

class _HousePainter extends CustomPainter {
  _HousePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(double x, double y) => Offset(x * s, y * s);
    final house = Path()
      ..moveTo(p(0.50, 0.08).dx, p(0.50, 0.08).dy)
      ..lineTo(p(0.96, 0.50).dx, p(0.96, 0.50).dy)
      ..lineTo(p(0.84, 0.50).dx, p(0.84, 0.50).dy)
      ..lineTo(p(0.84, 0.92).dx, p(0.84, 0.92).dy)
      ..lineTo(p(0.16, 0.92).dx, p(0.16, 0.92).dy)
      ..lineTo(p(0.16, 0.50).dx, p(0.16, 0.50).dy)
      ..lineTo(p(0.04, 0.50).dx, p(0.04, 0.50).dy)
      ..close()
      ..addRect(Rect.fromPoints(p(0.66, 0.14), p(0.78, 0.40)));
    final door = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromPoints(p(0.41, 0.60), p(0.59, 0.93)),
          topLeft: Radius.circular(0.063 * s),
          topRight: Radius.circular(0.063 * s),
        ),
      );
    final shape = Path.combine(PathOperation.difference, house, door);
    canvas.drawPath(
      shape,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shape,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.03 * s
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_HousePainter oldDelegate) => oldDelegate.color != color;
}
