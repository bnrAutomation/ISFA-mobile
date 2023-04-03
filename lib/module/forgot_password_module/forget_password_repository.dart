import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/forgot_password_module/model/forgot_password_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class ForgotPasswordRepository {
  Future<ForgotPasswordModel> forgotPassword({required String username}) async {
    final body = {"email": username};
    final response = await post(Uri.parse(URLConstants.forgotPassword),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return ForgotPasswordModel.fromRawJson(response.body);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }
}
