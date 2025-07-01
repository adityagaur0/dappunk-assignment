import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

Future<void> handleTransformedAudioShareOrDownload(String filePath) async {
  final file = File(filePath);

  if (!await file.exists()) {
    throw Exception('File does not exist: $filePath');
  }

  if (Platform.isIOS) {
    // iOS → Share
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Listen to my transformed voice!',
    );
  } else if (Platform.isAndroid) {
    // Android → Copy to Downloads
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    bool permissionGranted = false;

    if (sdkInt >= 33) {
      final statuses = await [
        Permission.audio,
        Permission.photos,
        Permission.videos,
      ].request();

      permissionGranted = statuses.values.any((status) => status.isGranted);

      if (statuses.values.any((status) => status.isPermanentlyDenied)) {
        await openAppSettings();
        throw Exception("Storage permission permanently denied. Please enable it in settings.");
      }
    } else {
      final status = await Permission.storage.request();
      permissionGranted = status.isGranted;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        throw Exception("Storage permission permanently denied. Please enable it in settings.");
      }
    }

    if (!permissionGranted) {
      throw Exception("Storage permission denied.");
    }

    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (!await downloadsDir.exists()) {
      throw Exception("Downloads directory not found");
    }

    final newFilePath = '${downloadsDir.path}/transformed_audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    final newFile = await file.copy(newFilePath);

    debugPrint('Saved to: ${newFile.path}');
  }
}
