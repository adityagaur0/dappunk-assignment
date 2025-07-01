// ------- UTILS ------- //

double normalizeAmplitude(double rawAmp) {
  const minDb = -15; // normal speaking volume
  const maxDb = -1; // very loud

  double normalized = (rawAmp - minDb) / (maxDb - minDb);
  return normalized.clamp(0, 1);
}
