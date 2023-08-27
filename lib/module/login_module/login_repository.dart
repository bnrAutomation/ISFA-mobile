import 'dart:convert';

import 'package:i_densfa/module/login_module/models/auth_model.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';

class LoginRepository {
  final client = CustomHttpBaseClient();

  Future<AuthenticateResponseModel> login(
      {required String username, required String password}) async {
    final body = {"username": username, "password": password};
    final response = await client.post(Uri.parse(URLConstants.login),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201) {
      return AuthenticateResponseModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<UserDetailsResponseModel> getUserDetails(userID) async {
    final response =
        await client.get(Uri.parse('${URLConstants.userDetails}/$userID'));
    if (response.statusCode == 200) {
      return UserDetailsResponseModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
