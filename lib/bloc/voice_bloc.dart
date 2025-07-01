import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/audio_capture_service.dart';
import '../shared/utils/audio_utils.dart';

sealed class AudioState {
  final double amplitude;
  const AudioState(this.amplitude);
}

class AudioInitial extends AudioState {
  const AudioInitial() : super(0);
}

class AudioUpdated extends AudioState {
  final List<double> waveform;
  // const AudioUpdated(super.amplitude);
  const AudioUpdated(super.amplitude, this.waveform);
}

class AudioBloc extends Cubit<AudioState> {
  final AudioCaptureService _audioService;

  AudioBloc(this._audioService) : super(const AudioInitial());

  Future<void> startRecording(String path) async {
    List<double> _waveform = [];

    try {
      await _audioService.start(
        path: path,
        onAmplitude: (rawamp) {
          final amp = normalizeAmplitude(rawamp);
          _waveform.add(amp);
          if (_waveform.length > 60) _waveform.removeAt(0);
          emit(AudioUpdated(amp, List.of(_waveform)));
        },
        onError: (error) => print('Error: $error'),
      );
    } catch (e) {
      print("Failed to start recording: $e");
    }
  }

  Future<void> stopRecording() async {
    await _audioService.stop();
  }

  Future<bool> isRecording() async {
    return _audioService.isRecording();
  }

  Future<void> dispose() async {
    await _audioService.dispose();
  }
}
