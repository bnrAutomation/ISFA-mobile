import 'dart:convert';

import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class PinLoginRepository {
  Future<LoginModel> verifyPin(
      {required String username, required String pin}) async {
    final body = {"username": username, "pin": pin};
    final response = await CustomHttpBaseClient().post(
        Uri.parse(URLConstants.loginwithpin),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 401) {
      throw "Incorrect Pin";
    } else if (response.statusCode == 200) {
      return LoginModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
