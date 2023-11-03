import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/login_module/models/auth_model.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';

class LoginRepository {
  Future<AuthenticateResponseModel> login(
      {required String username, required String password}) async {
    var name = await Device().name();
    var deviceId = await Device().deviceId();

    final body = {
      "username": username,
      "password": password,
      "userAgent": "${name}_$deviceId"
    };

    final response = await post(Uri.parse(URLConstants.login),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': name,
          'Device-Id': deviceId,
        });
    if (response.statusCode == 201) {
      return AuthenticateResponseModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<UserDetailsResponseModel> getUserDetails(userID) async {
    final response = await CustomHttpBaseClient()
        .get(Uri.parse('${URLConstants.userDetails}/$userID'));
    if (response.statusCode == 200) {
      return UserDetailsResponseModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
