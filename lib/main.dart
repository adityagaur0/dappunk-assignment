// import 'package:flutter/material.dart';
// import 'app.dart';
//
// void main() {
//   runApp(const VoiceBlobApp());
// }

import 'package:flutter/material.dart';
import 'features/voice_visualizer/ui/voice_visualizer_screen.dart';

void main() {
  runApp(const VoiceBlobApp());
}

class VoiceBlobApp extends StatelessWidget {
  const VoiceBlobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VoiceVisualizerScreen(),
    );
  }
}
