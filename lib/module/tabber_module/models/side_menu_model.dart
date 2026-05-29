import 'dart:convert';

class SideMenuModel {
  SideMenuModel({
    required this.sideMenu,
    required this.bottomMenu,
    required this.userInfo,
  });
  late final List<Menu> sideMenu;
  late final List<BottomMenu> bottomMenu;
  late final HomeUserInfo userInfo;

  factory SideMenuModel.fromRawJson(String str) =>
      SideMenuModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  SideMenuModel.fromJson(Map<String, dynamic> json) {
    sideMenu =
        List.from(json['sideMenu']).map((e) => Menu.fromJson(e)).toList();
    userInfo = HomeUserInfo.fromJson(json['user_info']);
    bottomMenu = List.from(json['bottomMenu'])
        .map((e) => BottomMenu.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sideMenu'] = sideMenu.map((e) => e.toJson()).toList();
    data['bottomMenu'] = bottomMenu.map((e) => e.toJson()).toList();
    data['user_info'] = userInfo.toJson();
    return data;
  }
}

class BottomMenu {
  BottomMenu({
    required this.name,
    required this.icon,
    required this.key,
    required this.active,
  });
  late final String name;
  late final String icon;
  late final String key;
  late final bool active;

  BottomMenu.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    icon = json['icon'];
    key = json['key'];
    active = json['isActive'] ?? json['active'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['icon'] = icon;
    data['key'] = key;
    data['isActive'] = active;
    return data;
  }
}

class Menu {
  Menu({
    required this.name,
    required this.icon,
    required this.key,
    required this.active,
  });
  late final String name;
  late final String icon;
  late final String key;
  late final bool active;

  Menu.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    icon = json['icon'];
    key = json['key'];
    active = json['isActive'] ?? json['active'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['icon'] = icon;
    data['key'] = key;
    data['isActive'] = active;
    return data;
  }

  factory Menu.fromRawJson(String str) => Menu.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

class HomeUserInfo {
  HomeUserInfo(
      {required this.mobile,
      required this.userName,
      required this.email,
      required this.companyId,
      required this.storeId,
      required this.companyName,
      required this.supervisor,
      required this.designation,
      required this.markInStoreId,
      required this.startDuty,
      required this.iRole});

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
  String iRole;

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
      startDuty: json["startDuty"] ?? false,
      iRole: json['role'] ?? "");

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
        "role": iRole
      };
}

enum TabbarItemCase { mystore,schedule, learner, campaign, analytics, settings }

extension TabbarHelper on TabbarItemCase {
  String navTitle() {
    switch (this) {
        case TabbarItemCase.mystore:
        return 'My Store';
      case TabbarItemCase.schedule:
        return 'My Schedule';
      case TabbarItemCase.learner:
        return 'Learner';
      case TabbarItemCase.campaign:
        return 'Campaign';
      case TabbarItemCase.analytics:
        return 'Analytics';
      case TabbarItemCase.settings:
        return 'Settings';
    }
  }

  String bottomTitle() {
    switch (this) {
        case TabbarItemCase.mystore:
        return 'My Store';
      case TabbarItemCase.schedule:
        return 'My Schedule';
      case TabbarItemCase.learner:
        return 'Learner';
      case TabbarItemCase.campaign:
        return 'Campaign';
      case TabbarItemCase.analytics:
        return 'Analytics';
      case TabbarItemCase.settings:
        return 'Settings';
    }
  }
}
