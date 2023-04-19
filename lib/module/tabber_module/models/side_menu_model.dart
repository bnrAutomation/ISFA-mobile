import 'dart:convert';

class SideMenuModel {
  SideMenuModel({
    required this.userInfo,
    required this.menu,
  });

  HomeUserInfo userInfo;
  List<Menu> menu;

  factory SideMenuModel.fromRawJson(String str) =>
      SideMenuModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SideMenuModel.fromJson(Map<String, dynamic> json) => SideMenuModel(
        userInfo: HomeUserInfo.fromJson(json["user_info"]),
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

class HomeUserInfo {
  HomeUserInfo({
    required this.mobile,
    required this.userName,
    required this.email,
    required this.companyId,
    required this.storeId,
    required this.companyName,
    required this.supervisor,
    required this.designation,
    required this.markInStoreId,
    required this.startDuty,
  });

  String mobile;
  String userName;
  String email;
  String supervisor;
  int companyId;
  int? storeId;
  String companyName;
  String designation;
  bool startDuty;
  int? markInStoreId;

  factory HomeUserInfo.fromRawJson(String str) =>
      HomeUserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HomeUserInfo.fromJson(Map<String, dynamic> json) => HomeUserInfo(
        mobile: json["mobile"] ?? "",
        userName: json["username"] ?? "N/A",
        email: json["email"],
        companyId: json["companyId"],
        storeId: (json["storeId"] ?? -1) > 0 ? json["storeId"] : null,
        companyName: json["companyName"] ?? "N/A",
        designation: json['designation'] ?? "",
        supervisor: json["supervisor"] ?? "",
        markInStoreId: json["markInStoreId"],
        startDuty: json["startDuty"],
      );

  Map<String, dynamic> toJson() => {
        "mobile": mobile,
        "username": userName,
        "email": email,
        "companyId": companyId,
        "companyName": companyName,
        "storeId": storeId,
        "startDuty": startDuty,
        "markInStoreId": markInStoreId,
        "designation": designation,
      };
}

enum TabbarItemCase { schedule, learner, campaign, analytics }

extension TabbarHelper on TabbarItemCase {
  String navTitle() {
    switch (this) {
      case TabbarItemCase.schedule:
        return 'My Schedule';
      default:
        return 'ISFA';
    }
  }

  String bottomTitle() {
    switch (this) {
      case TabbarItemCase.schedule:
        return 'My Schedule';
      case TabbarItemCase.learner:
        return 'Learner';
      case TabbarItemCase.campaign:
        return 'Campaign';
      case TabbarItemCase.analytics:
        return 'Analytics';
    }
  }
}
