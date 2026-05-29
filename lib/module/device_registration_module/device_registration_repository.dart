import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/login_device_headers.dart';
import 'package:i_densfa/utility/models/device_auth_payload.dart';

class DeviceRegistrationRepository {
  Future<DeviceRegistrationRequestResponse> submitRegistrationRequest({
    required String username,
    required String password,
    required String reason,
  }) async {
    final device = await Device().collectAuthDeviceInfo();
    final body = <String, dynamic>{
      'username': username.trim(),
      'password': encryptPassword(password.trim()),
      'reason': reason.trim(),
      'device': device.toJson(),
    };

    final response = await post(
      Uri.parse(URLConstants.deviceRegistrationRequest),
      body: jsonEncode(body),
      headers: loginDeviceHeaders(device),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeviceRegistrationRequestResponse.fromJson(json);
    }
    throw getErrorMessage(response);
  }

  Future<DeviceRegistrationRequestResponse> fetchRequestStatus({
    required String username,
  }) async {
    final uri = Uri.parse(URLConstants.deviceRegistrationStatus).replace(
      queryParameters: {'username': username.trim()},
    );
    final response = await get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeviceRegistrationRequestResponse.fromJson(json);
    }
    throw getErrorMessage(response);
  }
}
