import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';

typedef AudioListener = void Function(Float64List buffer);
typedef AudioErrorListener = void Function(Object error);

class AudioCaptureService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  Future<void> start({
    required String path,
    required Function(double) onAmplitude,
    required Function(dynamic) onError,
  }) async {
    try {
      print("P1: path: $path");
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _amplitudeSubscription = _recorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amplitude) {
        onAmplitude(amplitude.current);
      });
    } catch (e) {
      onError(e);
    }
  }

  Future<void> stop() async {
    await _amplitudeSubscription?.cancel();
    await _recorder.stop();
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  Future<void> dispose() async {
    await _amplitudeSubscription?.cancel();
    await _recorder.dispose();
  }
}
