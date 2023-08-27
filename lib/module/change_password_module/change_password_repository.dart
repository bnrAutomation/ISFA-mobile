import 'dart:convert';

import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class ChangePasswordRepository {
  final email = AppStorage().userDetail?.email;
  final client = CustomHttpBaseClient();
  Future<bool> changePassword(
      {required String oldPassword, required String newPassword}) async {
    final body = {
      "email": email,
      "newPassword": newPassword,
      "oldPassword": oldPassword
    };
    final response = await client.post(Uri.parse(URLConstants.updatePassword),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
