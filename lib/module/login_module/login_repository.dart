import 'package:http/http.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

import '../../utility/device_helper.dart';

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
