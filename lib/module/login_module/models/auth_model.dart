import 'dart:convert';

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
        message: json["message"] ?? "",
        status: json["status"],
        data: UserInfo.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "data": data.toJson(),
      };
}

class UserInfo {
  int id;
  String uuid;
  String email;
  String username;
  String supervisorId;
  int companyId;
  String designation;
  DateTime? lastLogin;
  String reportTo;
  String userStatus;
  String role;
  String mobile;
  String pin;
  String photoUrl;
  List<String> tags;
  String fullName;
  String city;
  String state;
  DateTime createdDate;
  String createdById;
  bool active;
  DateTime doj;

  UserInfo({
    required this.id,
    required this.uuid,
    required this.email,
    required this.username,
    required this.supervisorId,
    required this.companyId,
    required this.designation,
    required this.lastLogin,
    required this.reportTo,
    required this.userStatus,
    required this.role,
    required this.mobile,
    required this.pin,
    required this.photoUrl,
    required this.tags,
    required this.fullName,
    required this.city,
    required this.state,
    required this.createdDate,
    required this.createdById,
    required this.active,
    required this.doj,
  });

  factory UserInfo.fromRawJson(String str) =>
      UserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json["userId"] ?? "",
        uuid: json["uuid"] ?? "",
        email: json["email"] ?? "",
        username: json["username"] ?? "",
        supervisorId: json["supervisor"] ?? "",
        companyId: json["companyId"] ?? "",
        designation: json["designation"] ?? "",
        lastLogin: json["lastLogin"] != null
            ? DateTime.parse(json["lastLogin"])
            : null,
        reportTo: json["reportTo"] ?? "",
        userStatus: json["userStatus"] ?? "",
        role: json["role"] ?? '',
        mobile: json["mobile"] ?? "",
        pin: json["pin"] ?? "",
        photoUrl: json["photourl"] ?? "",
        tags: json["tags"] == null
            ? []
            : List<String>.from(json["tags"].map((x) => x)),
        fullName: json["fullName"] ?? json["username"] ?? "",
        city: json["city"] ?? "",
        state: json["state"] ?? "",
        createdDate: DateTime.parse(json["createdDate"]),
        createdById: json["createdBy"] ?? "",
        active: json["active"] ?? false,
        doj: DateTime.parse(json["doj"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": id,
        "uuid": uuid,
        "email": email,
        "username": username,
        "supervisor": supervisorId,
        "companyId": companyId,
        "designation": designation,
        "lastLogin": lastLogin?.toIso8601String(),
        "reportTo": reportTo,
        "userStatus": userStatus,
        "role": role,
        "mobile": mobile,
        "pin": pin,
        "photourl": photoUrl,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "fullName": fullName,
        "city": city,
        "state": state,
        "createdDate": createdDate.toIso8601String(),
        "createdBy": createdById,
        "active": active,
        "doj": createdDate.toIso8601String(),
      };
}
