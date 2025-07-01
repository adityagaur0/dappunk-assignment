import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voice_morph/shared/utils/download_audio_file.dart';
import '../../../bloc/voice_bloc.dart';
import '../../../hooks/use_mic_permission.dart';
import '../../../services/audio_capture_service.dart';
import '../../../services/transform_service.dart';
import '../../../shared/constants/colors.dart';
import '../../../shared/widgets/waveform_painter.dart';
import 'package:record/record.dart';

import '../widgets/button.dart';

class VoiceVisualizerScreen extends HookWidget {
  const VoiceVisualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    useAudioPermission();
    final audioBloc = useMemoized(() => AudioBloc(AudioCaptureService()));
    final isRecording = useState(false);
    final isTransformed = useState(false);
    final isTransforming = useState(false);
    final audioFilePath = useState<String?>(null);
    final transformedAudioFilePath = useState<String?>(null);
    final record = useMemoized(() => AudioRecorder());
    final audioPlayer = useMemoized(() => AudioPlayer());
    final selectedEffect = useState<String?>('male');
    final playerController = useMemoized(() => PlayerController());
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    useEffect(() {
      return audioBloc.stopListening;
    }, []);

    Future<void> play(String path) async {
      final file = File(path);
      if (!await file.exists()) {
        debugPrint('File does not exist: $path');
        return;
      }

      await audioPlayer.stop();
      debugPrint('Playing file: $path');
      await playerController.preparePlayer(path: path);
      await playerController.startPlayer();
      await audioPlayer.play(DeviceFileSource(path));
    }

    // Future<void> play(String path) async {
    //   await audioPlayer.stop();
    //   await audioPlayer.play(DeviceFileSource(path));
    // }
    useEffect(() {
      return () {
        playerController.dispose();
      };
    }, []);

    return BlocProvider.value(
      value: audioBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRecording.value) ...[
                  BlocBuilder<AudioBloc, AudioState>(
                    builder: (_, state) {
                      if (state is AudioUpdated) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 80,
                              width: double.infinity,
                              child: CustomPaint(
                                painter: WaveformPainter(state.waveform),
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox(height: 80);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                IconButton(
                  iconSize: 80,
                  color: Colors.white,
                  icon: Icon(isRecording.value ? Icons.mic_off : Icons.mic),
                  onPressed: () async {
                    if (isRecording.value) {
                      isRecording.value = false;
                      // audioBloc.stopListening();
                      await record.stop();
                      audioBloc.stopListening();
                    } else {
                      await audioPlayer.stop();
                      isRecording.value = true;
                      // audioBloc.startListening();
                      final dir = await getApplicationDocumentsDirectory();
                      // final filePath = "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.";
                      final filePath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
                      audioFilePath.value = filePath;
                      await record.start(
                        RecordConfig(
                          encoder: AudioEncoder.aacLc,
                          bitRate: 128000,
                          sampleRate: 44100,
                        ),
                        path: filePath,
                      );
                      audioBloc.startListening();
                      isTransformed.value = false;
                    }
                  },
                ),
                const SizedBox(height: 30),
                if (!isRecording.value && !isTransformed.value) ...[
                  DropdownButton<String>(
                    value: selectedEffect.value,
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white),
                    items: ['male', 'female', 'child', 'robot', 'deep', 'high_pitch']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) => selectedEffect.value = value,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (audioFilePath.value == null || selectedEffect.value == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Record first')),
                        );
                        return;
                      }
                      isTransforming.value = true;
                      try {
                        final newFilePath = await TransformService.transformAac(
                          inputPath: audioFilePath.value!,
                          effect: selectedEffect.value!,
                        );
                        transformedAudioFilePath.value = newFilePath;
                        isTransformed.value = true;
                      } catch (e) {
                        debugPrint("Transform failed: $e");
                        isTransformed.value = false;
                      } finally {
                        isTransforming.value = false;
                      }
                    },
                    child: const Text("Transform Audio"),
                  ),
                ],
                if (isTransforming.value) const SpinKitWave(color: Colors.white, size: 40),
                if (isTransformed.value)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text("Playback Options", style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BWButton(
                            icon: Icons.play_arrow,
                            label: "Original",
                            onPressed: () {
                              if (audioFilePath.value != null) {
                                play(audioFilePath.value!);
                              }
                            },
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BWButton(
                                icon: Icons.play_arrow,
                                label: "Transformed",
                                onPressed: () {
                                  if (transformedAudioFilePath.value != null) {
                                    play(transformedAudioFilePath.value!);
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              BWButton(
                                icon: Icons.download,
                                label: "Export",
                                onPressed: () async {
                                  final path = transformedAudioFilePath.value;
                                  if (path != null) {
                                    try {
                                      await handleTransformedAudioShareOrDownload(path);
                                      if (Platform.isAndroid) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Saved to Downloads')),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: AudioFileWaveforms(
                            size: Size(shortestSide * 0.9, 70),
                            playerController: playerController,
                            enableSeekGesture: true,
                            waveformType: WaveformType.fitWidth,
                            playerWaveStyle: const PlayerWaveStyle(
                              fixedWaveColor: Colors.white38,
                              liveWaveColor: Colors.white,
                              spacing: 6,
                              showSeekLine: true,
                            ),
                          ))
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
