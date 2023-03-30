import 'dart:convert';

class SideMenuModel {
  SideMenuModel({
    required this.userInfo,
    required this.menu,
  });

  UserInfo userInfo;
  List<Menu> menu;

  factory SideMenuModel.fromRawJson(String str) =>
      SideMenuModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SideMenuModel.fromJson(Map<String, dynamic> json) => SideMenuModel(
        userInfo: UserInfo.fromJson(json["user_info"]),
        menu: List<Menu>.from(json["menu"].map((x) => Menu.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "user_info": userInfo.toJson(),
        "menu": List<dynamic>.from(menu.map((x) => x.toJson())),
      };
}

class Menu {
  Menu({
    required this.name,
    required this.icon,
    required this.isActive,
    required this.key,
  });

  String name;
  String icon;
  bool isActive;
  String key;

  factory Menu.fromRawJson(String str) => Menu.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        name: json["name"],
        icon: json["icon"],
        isActive: json["isActive"],
        key: json["key"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "icon": icon,
        "isActive": isActive,
        "key": key,
      };
}

class UserInfo {
  UserInfo({
    this.phoneNo,
    this.role,
    required this.userName,
    required this.email,
  });

  String? phoneNo;
  String? role;
  String userName;
  String email;

  factory UserInfo.fromRawJson(String str) =>
      UserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        phoneNo: json["phone_no"],
        role: json["role"],
        userName: json["user_name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "phone_no": phoneNo,
        "role": role,
        "user_name": userName,
        "email": email,
      };
}
