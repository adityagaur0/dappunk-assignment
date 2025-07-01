import 'dart:typed_data';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';

typedef AudioListener = void Function(Float64List buffer);
typedef AudioErrorListener = void Function(Object error);

class AudioCaptureService {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();

  Future<void> initCapture(AudioListener onData, AudioErrorListener onError) async {
    await _audioCapture.init();
    await _audioCapture.start(
      (data) => onData(Float64List.fromList(data.cast<double>())),
      onError,
      sampleRate: 44100,
      bufferSize: 3000,
    );
  }

  Future<void> stopCapture() => _audioCapture.stop();
}
