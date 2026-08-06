import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/device_auth_exception.dart';

/// Parses authenticate / login error responses for device-binding failures.
DeviceAuthException? tryParseDeviceAuthException(Response response) {
  if (response.statusCode != 403) return null;
  try {
    final body = jsonDecode(response.body);
    if (body is! Map) return null;
    final code = (body['error'] ?? body['code'])?.toString() ?? '';
    if (code != DeviceAuthException.deviceNotAuthorizedCode) return null;
    final message = (body['message'] ??
            'You can only login using your registered device. Please use your authorized device or contact administrator.')
        .toString();
    return DeviceAuthException(code: code, message: message);
  } catch (_) {
    return null;
  }
}

void throwIfDeviceAuthError(Response response) {
  final deviceError = tryParseDeviceAuthException(response);
  if (deviceError != null) throw deviceError;
}
