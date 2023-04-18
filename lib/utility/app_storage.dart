import 'package:hive_flutter/hive_flutter.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';

class AppStorage {
  static final AppStorage _singleton = AppStorage._internal();

  factory AppStorage() {
    return _singleton;
  }

  AppStorage._internal();

  final String _prefrenceName = "isfa_prefrence";
  late Box _box;

  Future<AppStorage> _init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_prefrenceName);
    return this;
  }

  static Future<AppStorage> objectValue() async {
    return await AppStorage()._init();
  }

  UserInfo? get userDetail {
    final userRawJson = _box.get("user_detail");
    if (userRawJson is String) {
      return UserInfo.fromRawJson(userRawJson);
    }
    return null;
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
  bool? get isMarkedIn => _box.get("isMarkedIn");
  set isMarkedIn(bool? newVal) => _box.put("isMarkedIn", newVal);
}
