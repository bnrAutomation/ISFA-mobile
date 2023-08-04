import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/forgot_password_module/model/forgot_password_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/handler.dart';

class ResetPasswordRepository {
  Future<ForgotPasswordModel> resetPassword(
      {required String username,
      required String otp,
      required String password}) async {
    final body = {"email": username, "otp": otp, "password": password};
    final response = await post(Uri.parse(URLConstants.resetPassword),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return ForgotPasswordModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
