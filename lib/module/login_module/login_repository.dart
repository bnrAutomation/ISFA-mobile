import 'dart:io';

import 'package:http/http.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:i_densfa/utility/app_constants.dart';

class LoginRepository {
  final device = Device();
  Future<LoginResponse> userLogin(String userId, String userPassword) async {
    final requestBody = LoginRequest(
        appVersion: 0.01,
        deviceId: await device.deviceId(),
        deviceName: await device.name(),
        deviceOs: await device.deviceOs(),
        platform: device.plaform,
        userId: userId,
        userPassword: userPassword,
        userToken: '');
    final response = await post(Uri.parse(URLConstants.loginURl),
        body: requestBody.toJson());
    if (response.statusCode == 200) {
      return LoginResponse.fromRawJson(response.body);
    } else {
      throw response.reasonPhrase?.isEmpty ?? true
          ? 'Something went wrong'
          : response.reasonPhrase!;
    }
  }
}

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
