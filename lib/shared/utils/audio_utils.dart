import 'dart:math';
import 'dart:typed_data';

double calculateAmplitude(Float64List buffer) {
  double sum = buffer.fold(0.0, (p, e) => p + e * e);
  double rms = sqrt(sum / buffer.length);
  return rms.clamp(0, 1).toDouble();
}
