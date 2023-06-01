import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';

class SetPinRepository {
  Future<bool> setPin({required String username, required String pin}) async {
    final body = {"email": username, "pin": pin};
    final response = await post(Uri.parse(URLConstants.setpin),
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
