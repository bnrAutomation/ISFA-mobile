import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class Device {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<String> name() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine ?? 'iOS';
    }
    return '';
  }

  Future<String> deviceId() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      return iosInfo.identifierForVendor ?? '';
    }
    return '';
  }

  String get plaform {
    return "mobile";
  }

  Future<String> deviceOs() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.hardware;
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      return iosInfo.systemVersion ?? '';
    }
    return '';
  }
}
