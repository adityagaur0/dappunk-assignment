import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

class TransformService {
  static Future<String> transformAac({
    required String inputPath,
    required String effect,
  }) async {
    final dir = await getTemporaryDirectory();
    final outputPath = "${dir.path}/output_$effect.aac";

    String filter = switch (effect) {
      'male' => 'asetrate=44100*0.8,atempo=1.25',
      'female' => 'asetrate=44100*1.2,atempo=0.83',
      'child' => 'asetrate=44100*1.4,atempo=0.71',
      'robot' => 'afftfilt=real=\'hypot(re,im)\':imag=\'0\'',
      'deep' => 'asetrate=44100*0.6,atempo=1.66',
      'high_pitch' => 'asetrate=44100*1.5,atempo=0.67',
      _ => throw Exception('Unsupported effect')
    };

    final command = '-y -i "$inputPath" -af "$filter" "$outputPath"';
    await FFmpegKit.execute(command);

    if (!File(outputPath).existsSync()) {
      throw Exception('Failed to process audio.');
    }

    return outputPath;
  }

  static Future<String> convertToWav(String inputPath) async {
    final dir = await getTemporaryDirectory();
    final outputPath = "${dir.path}/output.wav";

    final command = '-y -i "$inputPath" -acodec pcm_s16le -ar 44100 -ac 1 "$outputPath"';
    await FFmpegKit.execute(command);

    if (!File(outputPath).existsSync()) {
      throw Exception('Failed to convert audio.');
    }

    return outputPath;
  }
}
