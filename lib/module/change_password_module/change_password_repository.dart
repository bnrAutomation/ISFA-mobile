import 'dart:convert';

import 'package:i_densfa/module/login_module/models/auth_model.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class ChangePasswordRepository {
  final email = AppStorage().userDetail?.email;
  final client = CustomHttpBaseClient.instance;
  Future<bool> changePassword(
      {required String oldPassword, required String newPassword}) async {
    final body = {
      "email": email,
      "newPassword": encryptPassword(newPassword),
      "oldPassword": encryptPassword(oldPassword)
    };
    final response = await client.post(Uri.parse(URLConstants.updatePassword),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<UserDetailsResponseModel> getUserDetails(userID) async {
    final response = await CustomHttpBaseClient.instance
        .get(Uri.parse('${URLConstants.userDetails}/$userID'));
    if (response.statusCode == 200) {
      return UserDetailsResponseModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }
}
