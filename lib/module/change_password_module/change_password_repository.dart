import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class ChangePasswordRepository {
  final email = AppStorage().userDetail?.email;
  Future<bool> changePassword(
      {required String oldPassword, required String newPassword}) async {
    final body = {
      "email": email,
      "newPassword": newPassword,
      "oldPassword": oldPassword
    };
    final response = await post(Uri.parse(URLConstants.updatePassword),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }
}
