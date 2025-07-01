import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;

  WaveformPainter(this.amplitudes);

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final barWidth = size.width / (amplitudes.length * 1.5);
    final spacing = barWidth * 0.5;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < amplitudes.length; i++) {
      final amp = amplitudes[i].clamp(0, 1);
      final x = i * (barWidth + spacing);
      final y = size.height / 2;
      final barHeight = amp * size.height * 0.4;

      canvas.drawLine(
        Offset(x, y - barHeight),
        Offset(x, y + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
