import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class PinLoginRepository {
  Future<LoginModel> verifyPin(
      {required String username, required String pin}) async {
    final body = {"username": username, "pin": pin};
    final response = await post(Uri.parse(URLConstants.loginwithpin),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return LoginModel.fromRawJson(response.body);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }
}
