import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPermission {
  static Future<bool> request() async {
    if (Platform.isAndroid) {
      final permissions = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ];

      final statuses = await permissions.request();

      return statuses.values.every((status) => status.isGranted);
    }

    return true;
  }
}
