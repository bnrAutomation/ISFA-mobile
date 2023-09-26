import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:i_densfa/utility/app_storage.dart';

String getErrorMessage(String responseBody) {
  try {
    final body = jsonDecode(responseBody);
    final String mess = body['message'] ?? body["error"];
    return mess;
  } catch (e) {
    return "Something went wrong";
  }
}

class CustomHttpBaseClient extends BaseClient {
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    if (AppStorage().authToken != null) {
      request.headers.addAll({
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${AppStorage().authToken}',
      });
    }
    log('👁️ ${request.method} => ${request.url.toString()}');
    if (request.headers.isNotEmpty) {
      log(request.headers.toString());
    }
    return request.send();
  }
}
