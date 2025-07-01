import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;

  WaveformPainter(this.amplitudes);

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / amplitudes.length;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = barWidth * 0.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < amplitudes.length; i++) {
      final amp = amplitudes[i];
      final x = i * barWidth;
      final y = size.height / 2;
      final barHeight = amp * size.height * 0.8;
      canvas.drawLine(Offset(x, y - barHeight), Offset(x, y + barHeight), paint);
    }
  }

  //
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
