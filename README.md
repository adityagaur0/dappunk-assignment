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
# 📁 lib Folder Structure

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
