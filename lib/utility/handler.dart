import 'dart:convert';

String getErrorMessage(String responseBody) {
  try {
    final body = jsonDecode(responseBody);
    final String mess = body['message'];
    return mess;
  } catch (e) {
    return "Something went wrong";
  }
}
