import 'package:hive_flutter/hive_flutter.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';

class AppStorage {
  static final AppStorage _singleton = AppStorage._internal();
  factory AppStorage() => _singleton;
  AppStorage._internal();

  final String _prefrenceName = "isfa_prefrence";
  late Box _box;

  static Future<AppStorage> objectValue() async => await AppStorage()._init();

  Future<AppStorage> _init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_prefrenceName);
    return this;
  }

  UserInfo? get userDetail {
    final String userRawJson = _box.get("user_detail");
    try {
      return UserInfo.fromRawJson(userRawJson);
    } catch (e) {
      return null;
    }
  }

  set userDetail(UserInfo? userInfo) =>
      _box.put("user_detail", userInfo?.toRawJson());

  bool isLoggedIn() => userDetail?.id != null;

  SideMenuModel? get homeInfo {
    final info = _box.get("home_info");
    if (info is String) {
      return SideMenuModel.fromRawJson(info);
    }
    return null;
  }

  set homeInfo(SideMenuModel? info) => _box.put("home_info", info?.toRawJson());

  bool get isDutyStarted => _box.get("isDutyStarted") ?? false;
  set isDutyStarted(bool newVal) => _box.put("isDutyStarted", newVal);
  int? get markedInStoreId => _box.get("markedInStoreId");
  set markedInStoreId(int? newVal) => _box.put("markedInStoreId", newVal);
  int get reminderCount => _box.get("reminderCount") ?? 0;
  set reminderCount(int newVal) => _box.put("reminderCount", newVal);
  set fcmToken(String? token) => _box.put("token", token);
  String? get fcmToken => _box.get("token");
  set authToken(String? authToken) => _box.put("authToken", authToken);
  String? get authToken => _box.get("authToken");
}
