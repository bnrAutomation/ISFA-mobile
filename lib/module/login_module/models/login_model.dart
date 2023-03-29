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

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['data'] = logindata.toJson();
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

class LoginData {
  LoginData({
    required this.userInfo,
  });
  late final UserInfo userInfo;

  LoginData.fromJson(Map<String, dynamic> json) {
    userInfo = UserInfo.fromJson(json['user_info']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['user_info'] = userInfo.toJson();
    return data;
  }
}

class UserInfo {
  UserInfo({
    required this.id,
    required this.username,
    required this.email,
    required this.supervisor,
    required this.companyId,
    this.designation = "",
    this.iRole = "",
    this.mobile = "",
    required this.roles,
  });
  late final int id;
  late final String username;
  late final String email;
  late final String supervisor;
  late final int companyId;
  late final String designation;
  late final String iRole;
  late final String mobile;
  late final List<Roles> roles;
  factory UserInfo.fromRawJson(String str) =>
      UserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    supervisor = json['supervisor'];
    companyId = json['companyId'];
    designation = json['designation'] ?? "";
    iRole = json['iRole'] ?? "";
    mobile = json['mobile'] ?? "";
    roles = List.from(json['roles']).map((e) => Roles.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['supervisor'] = supervisor;
    data['companyId'] = companyId;
    data['designation'] = designation;
    data['iRole'] = iRole;
    data['mobile'] = mobile;
    data['roles'] = roles.map((e) => e.toJson()).toList();
    return data;
  }
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

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
