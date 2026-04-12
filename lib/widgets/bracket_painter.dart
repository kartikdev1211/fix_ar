import 'package:flutter/material.dart';

class BracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool showTop, showBottom, showLeft, showRight;

  BracketPainter({
    required this.color,
    required this.strokeWidth,
    this.showTop = false,
    this.showBottom = false,
    this.showLeft = false,
    this.showRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    if (showTop && showLeft) {
      canvas.drawLine(Offset(0, h), Offset(0, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
    }
    if (showTop && showRight) {
      canvas.drawLine(Offset(w, h), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(0, 0), paint);
    }
    if (showBottom && showLeft) {
      canvas.drawLine(Offset(0, 0), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
    if (showBottom && showRight) {
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(w, h), Offset(0, h), paint);
    }
  }

  @override
  bool shouldRepaint(BracketPainter old) => false;
}