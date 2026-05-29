import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';

import '../forgot_password_module/model/forgot_password_model.dart';

class VerificationRepository {
  Future<ForgotPasswordModel> verifiOTP(
      {required String username, required String otp}) async {
    final body = {"emailId": username, "otp": otp};
    final response = await post(Uri.parse(URLConstants.verifyotp),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return ForgotPasswordModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<ForgotPasswordModel?> forgotPassword(
      {required String username}) async {
    final body = {"email": username};
    final response = await post(Uri.parse(URLConstants.forgotPassword),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return ForgotPasswordModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }
}
