# Voice_Morph

## Description:

A Flutter-Based Local Audio Transformer — this project allows users to perform audio transformation locally on their device, likely capturing, modifying, and playing back audio in real-time.

---

<details><summary>Recording(ANDROID/IOS)</summary>

### ANDROID

https://github.com/user-attachments/assets/c1cc1010-9c06-466b-a127-80497bd49ef4

### IOS

https://github.com/user-attachments/assets/b385cf21-bf50-4d99-8c5b-7d5fc064aa4c


</details> 

---
# Folder Structure

- lib/
  - main.dart
  - bloc/
    - voice_bloc.dart
  - features/
    - voice_visualizer/
      - ui/
        - voice_visualizer_screen.dart
      - widgets/
        - button.dart
  - hooks/
    - use_mic_permission.dart
  - services/
    - audio_capture_service.dart
    - transform_service.dart
  - shared/
    - constants/
      - colors.dart
    - utils/
      - audio_utils.dart
      - download_audio_file.dart
    - widgets/
      - blob_painter.dart
      - waveform_painter.dart
--
# Package Used:
  cupertino_icons: ^1.0.8
  permission_handler: ^11.4.0
  flutter_audio_capture: ^1.1.11
  path_provider: ^2.1.5
  flutter_hooks: ^0.21.2
  flutter_bloc: ^9.1.1
  flutter_spinkit: ^5.2.1
  record: ^6.0.0
  ffmpeg_kit_flutter_new: ^2.0.0
  share_plus: ^11.0.0
  audio_waveforms: ^1.3.0
  device_info_plus: ^11.3.0
  android_intent_plus: ^5.3.0
