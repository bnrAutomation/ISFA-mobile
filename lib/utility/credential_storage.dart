import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:i_densfa/utility/app_storage.dart';

class SavedCredentials {
  final bool remember;
  final String? username;
  final String? password;

  const SavedCredentials({
    required this.remember,
    this.username,
    this.password,
  });
}

/// Login credentials live in a dedicated Hive box that is never cleared on logout.
class CredentialStorage {
  static const _boxName = 'isfa_login_credentials';
  static const _securePasswordKey = 'saved_login_password';
  static const _hivePasswordKey = 'saved_password';
  static const _rememberKey = 'remember_credentials';
  static const _usernameKey = 'saved_username';

  static Box? _box;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> ensureInitialized() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
    await _migrateFromAppStorage();
  }

  static Future<void> _migrateFromAppStorage() async {
    final appStorage = AppStorage();
    if (!appStorage.rememberCredentials) return;

    final username = appStorage.savedUsername;
    if (username == null || username.isEmpty) return;

    await _box!.put(_rememberKey, true);
    await _box!.put(_usernameKey, username);

    String? password;
    try {
      password = await _storage.read(key: _securePasswordKey);
    } catch (_) {}

    if (password != null && password.isNotEmpty) {
      await _box!.put(_hivePasswordKey, _encodePassword(password));
    }

    appStorage.clearSavedCredentials();
    await _box!.flush();
  }

  static String _encodePassword(String password) =>
      base64Encode(utf8.encode(password));

  static String? _decodePassword(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return utf8.decode(base64Decode(encoded));
    } catch (_) {
      return null;
    }
  }

  static Future<void> persist({
    required bool remember,
    required String username,
    required String password,
  }) async {
    await ensureInitialized();

    if (remember) {
      await _box!.put(_rememberKey, true);
      await _box!.put(_usernameKey, username.trim());

      var savedSecurely = false;
      try {
        await _storage.write(key: _securePasswordKey, value: password);
        savedSecurely = true;
      } catch (e) {
        debugPrint('CredentialStorage: secure write failed: $e');
      }

      // Encoded backup when secure storage is unavailable on some devices.
      await _box!.put(_hivePasswordKey, _encodePassword(password));
      if (kDebugMode && !savedSecurely) {
        debugPrint('CredentialStorage: using Hive password backup');
      }
    } else {
      await _box!.delete(_rememberKey);
      await _box!.delete(_usernameKey);
      await _box!.delete(_hivePasswordKey);
      try {
        await _storage.delete(key: _securePasswordKey);
      } catch (_) {}
    }

    await _box!.flush();
  }

  static Future<SavedCredentials> loadSaved() async {
    await ensureInitialized();

    final remember = _box!.get(_rememberKey, defaultValue: false) == true;
    if (!remember) {
      return const SavedCredentials(remember: false);
    }

    final username = _box!.get(_usernameKey) as String?;
    String? password;

    try {
      password = await _storage.read(key: _securePasswordKey);
    } catch (e) {
      debugPrint('CredentialStorage: secure read failed: $e');
    }

    password ??= _decodePassword(_box!.get(_hivePasswordKey) as String?);

    return SavedCredentials(
      remember: true,
      username: username,
      password: password,
    );
  }

  static Future<void> clearAll() async {
    await ensureInitialized();
    await _box!.delete(_rememberKey);
    await _box!.delete(_usernameKey);
    await _box!.delete(_hivePasswordKey);
    try {
      await _storage.delete(key: _securePasswordKey);
    } catch (_) {}
    await _box!.flush();
  }
}
