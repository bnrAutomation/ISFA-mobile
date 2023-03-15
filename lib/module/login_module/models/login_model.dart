import 'dart:convert';

class LoginResponse {
  LoginResponse({
    required this.appList,
    required this.message,
    required this.passwordLastUpdated,
    required this.passwordReset,
    required this.pinStatus,
    required this.responseToken,
    required this.status,
    required this.statusCode,
    required this.userId,
    required this.userToken,
  });

  List<AppList> appList;
  String message;
  DateTime passwordLastUpdated;
  String passwordReset;
  String pinStatus;
  String responseToken;
  String status;
  int statusCode;
  String userId;
  String userToken;

  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        appList:
            List<AppList>.from(json["appList"].map((x) => AppList.fromJson(x))),
        message: json["message"],
        passwordLastUpdated: DateTime.parse(json["passwordLastUpdated"]),
        passwordReset: json["passwordReset"],
        pinStatus: json["pinStatus"],
        responseToken: json["responseToken"],
        status: json["status"],
        statusCode: json["statusCode"],
        userId: json["userId"],
        userToken: json["userToken"],
      );

  Map<String, dynamic> toJson() => {
        "appList": List<dynamic>.from(appList.map((x) => x.toJson())),
        "message": message,
        "passwordLastUpdated": passwordLastUpdated.toIso8601String(),
        "passwordReset": passwordReset,
        "pinStatus": pinStatus,
        "responseToken": responseToken,
        "status": status,
        "statusCode": statusCode,
        "userId": userId,
        "userToken": userToken,
      };
}

class AppList {
  AppList({
    required this.appVersion,
    required this.campId,
    required this.campName,
    required this.name,
    required this.url,
  });

  String appVersion;
  String campId;
  String campName;
  String name;
  String url;

  factory AppList.fromRawJson(String str) => AppList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppList.fromJson(Map<String, dynamic> json) => AppList(
        appVersion: json["appVersion"],
        campId: json["campId"],
        campName: json["campName"],
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "appVersion": appVersion,
        "campId": campId,
        "campName": campName,
        "name": name,
        "url": url,
      };
}

class LoginRequest {
  LoginRequest({
    required this.appVersion,
    required this.deviceId,
    required this.deviceName,
    required this.deviceOs,
    required this.platform,
    required this.userId,
    required this.userPassword,
    required this.userToken,
  });

  double appVersion;
  String deviceId;
  String deviceName;
  String deviceOs;
  String platform;
  String userId;
  String userPassword;
  String userToken;

  factory LoginRequest.fromRawJson(String str) =>
      LoginRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        appVersion: json["appVersion"],
        deviceId: json["deviceId"],
        deviceName: json["deviceName"],
        deviceOs: json["deviceOS"],
        platform: json["platform"],
        userId: json["userId"],
        userPassword: json["userPassword"],
        userToken: json["userToken"],
      );

  Map<String, String> toJson() => {
        "appVersion": appVersion.toString(),
        "deviceId": deviceId,
        "deviceName": deviceName,
        "deviceOS": deviceOs,
        "platform": platform,
        "userId": userId,
        "userPassword": userPassword,
        "userToken": userToken,
      };
}
