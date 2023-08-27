import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/login_verify_module/pin_login_repository.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';

class SettingsRespository {
  final userDetails = AppStorage().userDetail!;
  Future<String> updateProfilePic(XFile profilePic) async {
    final url = Uri.parse('${URLConstants.updateProfilePic}/${userDetails.id}');
    final request = MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer ${AppStorage().authToken}',
    });
    final multipartFile =
        await MultipartFile.fromPath('image', profilePic.path);

    request.files.add(multipartFile);

    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      // = LoginModel.fromRawJson(body).logindata.userInfo;
      var loginModel = await PinLoginRepository()
          .verifyPin(username: userDetails.username, pin: userDetails.pin);

      AppStorage().userDetail = loginModel.logindata.userInfo;
      return json.decode(body)['message'] ?? "";
    } else {
      throw body.isEmpty
          ? "Something went wrong"
          : json.decode(body)['message'] ?? "Something went wrong";
    }
  }
}
