import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y)
      ..lineTo(x / 2, 0)
      ..lineTo(x, y)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double boxHalfWidth = size.width * 0.3;
    final double boxHalfHeight = size.height * 0.2;
    final p = Path()
      ..moveTo(center.dx - boxHalfWidth, center.dy - boxHalfHeight)
      ..lineTo(center.dx + boxHalfWidth, center.dy - boxHalfHeight)
      ..lineTo(center.dx + boxHalfWidth, center.dy + boxHalfHeight)
      ..lineTo(center.dx - boxHalfWidth, center.dy + boxHalfHeight)
      ..close();

    return Path()
      ..addRRect(
          RRect.fromRectAndRadius(p.getBounds(), const Radius.circular(20)));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
