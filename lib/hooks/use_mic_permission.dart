import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:permission_handler/permission_handler.dart';

useAudioPermission() {
  useEffect(() {
    Future.microtask(() async {
      final status = await Permission.microphone.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    });
    return null;
  }, []);
}
