import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BlobPainter extends CustomPainter {
  final double amplitude;
  final double tick;
  final int points;

  BlobPainter({required this.amplitude, required this.tick, this.points = 32});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = AppColors.blob.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * pi;
      final noise = sin(angle * 3 + tick * 2 * pi) * amplitude * 50;
      final r = radius + noise;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BlobPainter oldDelegate) => oldDelegate.amplitude != amplitude || oldDelegate.tick != tick;
}
