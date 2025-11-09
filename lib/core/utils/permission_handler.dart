import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  static Future<bool> checkStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
} 