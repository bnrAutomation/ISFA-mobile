import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/login_module/models/auth_model.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_auth_helper.dart';
import 'package:i_densfa/utility/device_helper.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/login_device_headers.dart';

class PinLoginRepository {
  final userId = AppStorage().userDetail!.id;
  Future<UserInfo> verifyPinSetting(
      {required String username, required String pin}) async {
    final body = {"username": username, "pin": pin};
    final response = await post(Uri.parse(URLConstants.loginwithpin),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 401) {
      if (getErrorMessage(response) == 'Token is invalid') {
        throw 'Please login instead';
      }
      if (kDebugMode) {
        debugPrint('verifyPinSetting: unauthorized (401)');
      }
      if (kDebugMode) {
        debugPrint(AppStorage().userDetail?.pin);
      }
      throw "Incorrect Pin";
    } else if (response.statusCode == 200) {
      return await _getUserDetails();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<AuthenticateResponseModel> verifyPin(
      {required String username, required String pin}) async {
    final device = await Device().collectAuthDeviceInfo();
    final body = {
      "username": username,
      "pin": pin,
      "userAgent": "${device.deviceName}_${device.deviceUniqueId}",
      "device": device.toJson(),
    };
    final response = await post(
      Uri.parse(URLConstants.login),
      body: jsonEncode(body),
      headers: loginDeviceHeaders(device),
    );
    if (kDebugMode) {
      debugPrint('verifyPin: status ${response.statusCode}');
    }
    if (response.statusCode == 201) {
      return AuthenticateResponseModel.fromRawJson(response.body);
    }
    throwIfDeviceAuthError(response);
    if (response.statusCode == 403) {
      throw "Please enter valid Pin";
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

  Future<UserInfo> _getUserDetails() async {
    final response = await CustomHttpBaseClient.instance
        .get(Uri.parse('${URLConstants.userDetails}/$userId'));
    if (response.statusCode == 200) {
      return UserDetailsResponseModel.fromRawJson(response.body).data;
    }
    else {
      throw getErrorMessage(response);
    }
  }
}
