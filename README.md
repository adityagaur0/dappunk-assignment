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

---
# Package Used:
  - cupertino_icons: ^1.0.8
  - permission_handler: ^11.4.0
  - flutter_audio_capture: ^1.1.11
  - path_provider: ^2.1.5
  - flutter_hooks: ^0.21.2
  - flutter_bloc: ^9.1.1
  - flutter_spinkit: ^5.2.1
  - record: ^6.0.0
  - ffmpeg_kit_flutter_new: ^2.0.0
  - share_plus: ^11.0.0
  - audio_waveforms: ^1.3.0
  - device_info_plus: ^11.3.0
  android_intent_plus: ^5.3.0

---
##  Modules Overview

| Module | Responsibility |
|--------|----------------|
| `AudioBloc` | Manages recording state & waveform updates |
| `AudioCaptureService` | Interfaces with microphone input using `record` |
| `WaveformPainter` | Renders real-time waveform visuals |
| `TransformService` | Applies FFmpeg audio effects (pitch/speed) |
| `handleTransformedAudioShareOrDownload` | Exports audio to Downloads (Android) or shares (iOS) |
| `useAudioPermission` | Requests microphone permission on widget load |

---

## 🔁 Data Flow

```plaintext
[User taps Record]
   ↓
AudioBloc.startRecording()
   ↓
AudioCaptureService.start() starts microphone & amplitude listener
   ↓
Amplitude values every 100ms → normalizeAmplitude()
   ↓
Emit AudioUpdated(amplitude, waveform)
   ↓
WaveformPainter renders live waveform

[User taps Stop]
   ↓
AudioBloc.stopRecording()

[User selects effect + taps Transform]
   ↓
TransformService.transformAac(path, effect)
   ↓
Output file stored → available for playback/export

[User taps Export]
   ↓
iOS → Share via share_plus
Android → Save to Downloads folder
```

---

# Audio Bloc
`Future<void> startRecording(String path)`
- Starts microphone using AudioCaptureService
- Captures amplitude every 100ms
- Emits AudioUpdated with amplitude & waveform
- Maintains only the last 60 values


# AudioCaptureService
`AudioRecorder _recorder = AudioRecorder();`

Uses record package to:
- Start/stop recording to .aac
- Subscribe to amplitude updates via stream


# WaveformPainter

- Paints bars for each amplitude on a Canvas
- Bar height proportional to amplitude
- Adjusts spacing and strokeWidth dynamically

# TransformService

`transformAac({ inputPath, effect })`

- Uses FFmpegKit to apply transformations:

| Effect      | Filter Applied                          |
| ----------- | --------------------------------------- |
| male        | `asetrate=44100*0.8,atempo=1.25`        |
| female      | `asetrate=44100*1.2,atempo=0.83`        |
| child       | `asetrate=44100*1.4,atempo=0.71`        |
| robot       | `afftfilt=real='hypot(re,im)':imag='0'` |
| deep        | `asetrate=44100*0.6,atempo=1.66`        |
| high\_pitch | `asetrate=44100*1.5,atempo=0.67`        |

- Outputs an .aac file in the temporary directory

# File Export

`handleTransformedAudioShareOrDownload(path)`
iOS:
- Shares via share_plus

Android:
- Requests appropriate storage permissions (based on SDK version)
- Copies file to /storage/emulated/0/Download

#  Permission Handling

`useAudioPermission()`

- Hook-based mic permission request
- On permanent denial, opens app settings


