import 'package:hive_flutter/hive_flutter.dart';
import 'package:i_densfa/module/login_module/models/auth_model.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';

class AppStorage {
  static final AppStorage _singleton = AppStorage._internal();
  factory AppStorage() => _singleton;
  AppStorage._internal();

  final String _prefrenceName = "isfa_prefrence";
  late Box _box;

  // Cache for parsed objects to avoid repeated JSON parsing
  UserInfo? _cachedUserDetail;
  SideMenuModel? _cachedHomeInfo;
  
  // Cache version tracking to invalidate cache when data changes
  String? _cachedUserDetailVersion;
  String? _cachedHomeInfoVersion;

  static Future<AppStorage> objectValue() async => await AppStorage()._init();

  Future<AppStorage> _init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_prefrenceName);
    return this;
  }

  void logout() {
    _box.clear();
    // Clear cached objects
    _cachedUserDetail = null;
    _cachedHomeInfo = null;
    _cachedUserDetailVersion = null;
    _cachedHomeInfoVersion = null;
    // Device keys cleared with _box.clear()
  }

  /// Optimized userDetail getter with caching
  /// Avoids repeated JSON parsing on every access
  UserInfo? get userDetail {
    try {
      final String? userRawJson = _box.get("user_detail");
      
      // Return null if no data stored
      if (userRawJson == null || userRawJson.isEmpty) {
        _cachedUserDetail = null;
        _cachedUserDetailVersion = null;
        return null;
      }
      
      // Return cached object if data hasn't changed
      if (_cachedUserDetailVersion == userRawJson && _cachedUserDetail != null) {
        return _cachedUserDetail;
      }
      
      // Parse and cache the new data
      _cachedUserDetail = UserInfo.fromRawJson(userRawJson);
      _cachedUserDetailVersion = userRawJson;
      return _cachedUserDetail;
    } catch (e) {
      // Clear corrupted cache on error
      _cachedUserDetail = null;
      _cachedUserDetailVersion = null;
      return null;
    }
  }

  /// Optimized userDetail setter
  set userDetail(UserInfo? userInfo) {
    if (userInfo == null) {
      _box.delete("user_detail");
      _cachedUserDetail = null;
      _cachedUserDetailVersion = null;
    } else {
      final jsonString = userInfo.toRawJson();
      _box.put("user_detail", jsonString);
      // Update cache immediately
      _cachedUserDetail = userInfo;
      _cachedUserDetailVersion = jsonString;
    }
  }

  bool isLoggedIn() => userDetail?.id != null;

  /// Optimized homeInfo getter with caching
  SideMenuModel? get homeInfo {
    try {
      final info = _box.get("home_info");
      
      // Return null if no data stored
      if (info == null || (info is String && info.isEmpty)) {
        _cachedHomeInfo = null;
        _cachedHomeInfoVersion = null;
        return null;
      }
      
      if (info is String) {
        // Return cached object if data hasn't changed
        if (_cachedHomeInfoVersion == info && _cachedHomeInfo != null) {
          return _cachedHomeInfo;
        }
        
        // Parse and cache the new data
        _cachedHomeInfo = SideMenuModel.fromRawJson(info);
        _cachedHomeInfoVersion = info;
        return _cachedHomeInfo;
      }
      
      return null;
    } catch (e) {
      // Clear corrupted cache on error
      _cachedHomeInfo = null;
      _cachedHomeInfoVersion = null;
      return null;
    }
  }

  /// Optimized homeInfo setter
  set homeInfo(SideMenuModel? info) {
    if (info == null) {
      _box.delete("home_info");
      _cachedHomeInfo = null;
      _cachedHomeInfoVersion = null;
    } else {
      final jsonString = info.toRawJson();
      _box.put("home_info", jsonString);
      // Update cache immediately
      _cachedHomeInfo = info;
      _cachedHomeInfoVersion = jsonString;
    }
  }
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
  
  /// Last FCM token and app version successfully sent to backend.
  String? get lastFcmTokenSent => _box.get("lastFcmTokenSent");
  set lastFcmTokenSent(String? value) => _box.put("lastFcmTokenSent", value);

  String? get lastFcmAppVersionSent => _box.get("lastFcmAppVersionSent");
  set lastFcmAppVersionSent(String? value) =>
      _box.put("lastFcmAppVersionSent", value);

  /// Bound device fingerprint (set on successful login).
  String? get registeredDeviceFingerprint =>
      _box.get("registered_device_fingerprint");
  set registeredDeviceFingerprint(String? value) {
    if (value == null) {
      _box.delete("registered_device_fingerprint");
    } else {
      _box.put("registered_device_fingerprint", value);
    }
  }

  String? get registeredDeviceUniqueId => _box.get("registered_device_unique_id");
  set registeredDeviceUniqueId(String? value) {
    if (value == null) {
      _box.delete("registered_device_unique_id");
    } else {
      _box.put("registered_device_unique_id", value);
    }
  }

  String? get registeredDevicePlatform => _box.get("registered_device_platform");
  set registeredDevicePlatform(String? value) {
    if (value == null) {
      _box.delete("registered_device_platform");
    } else {
      _box.put("registered_device_platform", value);
    }
  }

  /// Clear all caches - useful for debugging or manual cache invalidation
  void clearCache() {
    _cachedUserDetail = null;
    _cachedHomeInfo = null;
    _cachedUserDetailVersion = null;
    _cachedHomeInfoVersion = null;
  }
}
