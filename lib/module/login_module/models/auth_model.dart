import 'dart:convert';

import 'login_model.dart';

class AuthenticateResponseModel {
  final String accessToken;
  final String tokenType;
  final int tokeExpiry;

  AuthenticateResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.tokeExpiry,
  });

  factory AuthenticateResponseModel.fromRawJson(String str) =>
      AuthenticateResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthenticateResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthenticateResponseModel(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        tokeExpiry: json["toke_expiry"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
        "toke_expiry": tokeExpiry,
      };

  String getUserId() {
    final parts = accessToken.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }
    return payloadMap['sub'];
  }
}

class UserDetailsResponseModel {
  final String message;
  final int status;
  final UserInfo data;

  UserDetailsResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory UserDetailsResponseModel.fromRawJson(String str) =>
      UserDetailsResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      UserDetailsResponseModel(
        message: json["message"],
        status: json["status"],
        data: UserInfo.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "data": data.toJson(),
      };
}
