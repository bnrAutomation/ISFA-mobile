import 'dart:convert';

class LoginModel {
  LoginModel({
    required this.logindata,
    required this.message,
    required this.status,
  });
  late final LoginData logindata;
  late final String message;
  late final int status;

  factory LoginModel.fromRawJson(String str) =>
      LoginModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  LoginModel.fromJson(Map<String, dynamic> json) {
    logindata = LoginData.fromJson(json['data']);
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() =>
      {'data': logindata.toJson(), 'message': message, 'status': status};
}

class LoginData {
  LoginData({
    required this.userInfo,
  });
  late final UserInfo userInfo;

  LoginData.fromJson(Map<String, dynamic> json) {
    userInfo = UserInfo.fromJson(json['user_info']);
  }

  Map<String, dynamic> toJson() => {'user_info': userInfo.toJson()};
}

class UserInfo {
  UserInfo({
    required this.id,
    required this.username,
    required this.email,
    required this.supervisor,
    required this.companyId,
    this.designation = "",
    this.mobile = "",
    required this.pin,
    required this.role,
    required this.photoUrl,
  });
  late final int id;
  late final String username;
  late final String email;
  late final String supervisor;
  late final int companyId;

  late final String designation;

  late final String mobile;
  late String pin;
  late String photoUrl;
  late final String role;

  factory UserInfo.fromRawJson(String str) =>
      UserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  UserInfo.fromJson(Map<String, dynamic> json) {
    photoUrl = json['photourl'] ?? "";
    id = json['userId'];
    username = json['username'];
    email = json['email'];
    supervisor = json['supervisor'];
    companyId = json['companyId'];
    designation = json['designation'] ?? "";
    mobile = json['mobile'] ?? "";
    pin = json['pin'] ?? "-1";
    role = json['role'];
  }

  Map<String, dynamic> toJson() => {
        'userId': id,
        'username': username,
        'email': email,
        'supervisor': supervisor,
        'companyId': companyId,
        'designation': designation,
        'pin': pin,
        'mobile': mobile,
        'photourl': photoUrl,
        'role': role,
      };
}

class Roles {
  Roles({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
