import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/handler.dart';

class LoginRepository {
  Future<LoginModel> login(
      {required String username, required String password}) async {
    final body = {"username": username, "password": password};
    final response = await post(Uri.parse(URLConstants.login),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return LoginModel.fromRawJson(response.body);
    } else if (response.statusCode == 401) {
      throw "Incorrect Username or Password";
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
