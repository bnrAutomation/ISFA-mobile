import 'package:hive_flutter/hive_flutter.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:path_provider/path_provider.dart';

class AppStorage {
  String prefrenceName = "isfa_admin_prefrence";
  late Box stroagePrefrence;
  AppStorage._();

  Future<AppStorage> _init() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(documentDirectory.path);
    stroagePrefrence = await Hive.openBox(prefrenceName);
    return this;
  }

  static Future<AppStorage> objectValue() async {
    return await AppStorage._()._init();
  }

  UserInfo get userDetail =>
      UserInfo.fromRawJson(stroagePrefrence.get("user_detail"));

  set userDetail(UserInfo userInfo) =>
      stroagePrefrence.put("user_detail", userInfo.toRawJson());

  bool isLoggedIn() => stroagePrefrence.containsKey("user_detail");
}
