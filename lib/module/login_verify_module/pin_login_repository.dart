import 'dart:convert';

import 'package:i_densfa/module/login_module/models/auth_model.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';

class PinLoginRepository {
  final client = CustomHttpBaseClient();
  final userId = AppStorage().userDetail!.id;

  Future<UserInfo> verifyPin(
      {required String username, required String pin}) async {
    final body = {"username": username, "pin": pin};
    final response = await client.post(Uri.parse(URLConstants.loginwithpin),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 401) {
      if (getErrorMessage(response.body) == 'Token is invalid') {
        throw 'Please login instead';
      }
      throw "Incorrect Pin";
    } else if (response.statusCode == 200) {
      return await _getUserDetails();
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<UserInfo> _getUserDetails() async {
    final response =
        await client.get(Uri.parse('${URLConstants.userDetails}/$userId'));
    if (response.statusCode == 200) {
      return UserDetailsResponseModel.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
