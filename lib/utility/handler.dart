import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:i_densfa/utility/app_storage.dart';

String getErrorMessage(String responseBody) {
  try {
    final body = jsonDecode(responseBody);
    final String mess = body['message'];
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
        'Authorization': 'Bearer ${AppStorage().authToken}',
      });
    }
    log('👁️${request.method} => ${request.url.toString()}');
    log(request.headers.toString());
    final streamedResponse = await request.send();
    final response = await Response.fromStream(streamedResponse);
    log('Response :- ${response.statusCode}');
    log(response.body);
    return streamedResponse;
  }
}
