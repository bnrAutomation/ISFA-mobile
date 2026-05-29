import 'dart:convert';

import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';

class SetPinRepository {
  Future<bool> setPin({required String username, required String pin}) async {
    final body = {"email": username, "pin": pin};
    final response = await CustomHttpBaseClient.instance.post(
        Uri.parse(URLConstants.setpin),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }
}
