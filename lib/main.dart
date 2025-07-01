// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const VoiceBlobApp());
}

class VoiceBlobApp extends StatelessWidget {
  const VoiceBlobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Blob',
      debugShowCheckedModeBanner: false,
      home: const VoiceVisualizer(),
    );
  }
}

class VoiceVisualizer extends StatefulWidget {
  const VoiceVisualizer({super.key});

  @override
  State<VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<VoiceVisualizer> with SingleTickerProviderStateMixin {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  double _amplitude = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _requestMicPermission();
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    print("Mic permission status: $status");

    if (status.isGranted) {
      _startCapture();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      print("Microphone permission denied");
    }
  }

  void _startCapture() async {
    try {
      await _audioCapture.init();

      await _audioCapture.start(listener, onError, sampleRate: 44100, bufferSize: 3000);
    } catch (e) {
      print("Failed to start audio capture: $e");
    }
  }

  void listener(dynamic obj) {
    final buffer = Float64List.fromList(obj.cast<double>());
    double sum = 0;
    for (var i = 0; i < buffer.length; i++) {
      sum += buffer[i] * buffer[i];
    }
    final rms = sqrt(sum / buffer.length);
    final amp = rms.clamp(0, 1).toDouble();
    setState(() {
      _amplitude = amp;
    });
  }

  void onError(Object e) {
    print("Audio capture error: $e");
  }

  @override
  void dispose() {
    _audioCapture.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = 150 + _amplitude * 100;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: BlobPainter(amplitude: _amplitude, tick: _controller.value),
            child: SizedBox(width: size, height: size),
          ),
        ),
      ),
    );
  }
}

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
      ..color = Colors.blueAccent.withOpacity(0.8)
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
