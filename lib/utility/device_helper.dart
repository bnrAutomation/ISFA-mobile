import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/image_compression_helper.dart';
import 'package:i_densfa/utility/models/device_auth_payload.dart';
import 'package:image/image.dart' as img;
import 'package:package_info_plus/package_info_plus.dart';

class LocationSpoofingException implements Exception {
  final String message;
  LocationSpoofingException(this.message);
  @override
  String toString() => message;
}

class _LastFix {
  final double lat;
  final double lng;
  final DateTime at;
  _LastFix(this.lat, this.lng, this.at);
}

class Device {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final userId = AppStorage().userDetail?.id ?? "";
  static _LastFix? _lastSecureFix;
  static const MethodChannel _securityChannel =
      MethodChannel('com.denave.isfa/security');
  static DateTime? _devOptionsCheckedAt;
  static bool? _devOptionsLastResult;
  static const Duration _devOptionsCacheTtl = Duration(seconds: 45);

  Future<bool> _isDeveloperOptionsEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      await _securityChannel.invokeMethod<bool>('isDeveloperOptionsEnabled');
      return false;
    } catch (_) {
      // Fail-open to avoid blocking users if the channel isn't available.
      return false;
    }
  }

  /// Cached read for high-frequency checks (e.g. position stream).
  Future<bool> isDeveloperOptionsEnabledCached({
    Duration ttl = _devOptionsCacheTtl,
  }) async {
    final now = DateTime.now();
    if (_devOptionsCheckedAt != null &&
        now.difference(_devOptionsCheckedAt!) < ttl &&
        _devOptionsLastResult != null) {
      return _devOptionsLastResult!;
    }
    final v = await _isDeveloperOptionsEnabled();
    _devOptionsCheckedAt = now;
    _devOptionsLastResult = v;
    ///return true;
    return v;
  }

  /// Returns `null` if location services and permission allow reads.
  /// Otherwise a user-facing message (same strings as [userPosition] errors).
  Future<String?> locationAvailabilityIssue() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled.Please enable to continue';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permissions are permanently denied, we cannot request permissions.';
    }
    return null;
  }

  /// Applies mock / fix-age / jump / speed rules and updates [_lastSecureFix]
  /// when the sample is accepted. Returns `null` on success, otherwise a
  /// rejection message (no state change on rejection).
  String? commitSecurePositionIfValid(
    Position pos,
    DateTime now, {
    int maxFixAgeSeconds = 90,
    double maxSpeedMps = 80,
    double maxJumpMeters = 5000,
    int minJumpWindowSeconds = 60,
  }) {
    if (Platform.isAndroid && pos.isMocked) {
      return 'Mock location detected. Please disable mock location apps / settings and try again.';
    }

    final ts = pos.timestamp;
    final ageSeconds = now.difference(ts).inSeconds.abs();
    if (ageSeconds > maxFixAgeSeconds) {
      return 'Unable to get a fresh GPS fix. Please try again in an open area.';
    }

    final last = _lastSecureFix;
    if (last != null) {
      final dt = now.difference(last.at).inSeconds;
      if (dt > 0) {
        final dist = Geolocator.distanceBetween(
            last.lat, last.lng, pos.latitude, pos.longitude);
        final speed = dist / dt;
        if (dt <= minJumpWindowSeconds && dist >= maxJumpMeters) {
          return 'Suspicious location change detected. Please disable GPS spoofing and try again.';
        }
        if (speed.isFinite && speed > maxSpeedMps) {
          return 'Unrealistic movement detected. Please disable GPS spoofing and try again.';
        }
      }
    }

    _lastSecureFix = _LastFix(pos.latitude, pos.longitude, now);
    return null;
  }

  /// Same anti-spoof rules as [secureUserPosition], for an existing [Position]
  /// (e.g. from a stream). Updates [_lastSecureFix] only when returning `null`.
  Future<String?> secureRejectionReasonForPosition(
    Position pos, {
    int maxFixAgeSeconds = 90,
    double maxSpeedMps = 80,
    double maxJumpMeters = 5000,
    int minJumpWindowSeconds = 60,
  }) async {
    if (await isDeveloperOptionsEnabledCached()) {
      return 'Developer options are enabled. Please disable Developer options to continue.';
    }
    return commitSecurePositionIfValid(
      pos,
      DateTime.now(),
      maxFixAgeSeconds: maxFixAgeSeconds,
      maxSpeedMps: maxSpeedMps,
      maxJumpMeters: maxJumpMeters,
      minJumpWindowSeconds: minJumpWindowSeconds,
    );
  }

  Future<String> compressImageWidget(String file, String text, String name,
      {int? reduceSize}) async {
    return await ImageCompressionHelper.instance.compressImage(
      file,
      name,
      quality: reduceSize,
      addText: text,
    );
  }

  Future<String> compressImage(String file, String text, String name,
      {int? reduceSize}) async {
    return await ImageCompressionHelper.instance.compressImage(
      file,
      name,
      quality: reduceSize,
      addText: text,
      convertToJpg: true,
    );
  }


  Future<String> addTextToImage(File imageFile, String text) async {
    // Load the image
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // Draw text on the image
    img.drawString(
      image,
      text,
      font: img.arial24, // Use built-in Arial font (24px)
      x: 10, // X position
      y: 10, // Y position
      wrap: true, // Enable text wrapping
    );

    // Return the modified image as bytes (no file creation)
    // return Uint8List.fromList(img.encodeJpg(image));
    final file = await File(imageFile.path).writeAsBytes(img.encodeJpg(image));
    return file.path;
  }

  Future<String> addTextToImagex(String imageFile, String text) async {
    // Load the image
    final imageBytes = await File(imageFile).readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // Draw text on the image
    img.drawString(
      image,
      text,
      font: img.arial24, // Use built-in Arial font (24px)
      x: 10, // X position
      y: 10, // Y position
      wrap: true, // Enable text wrapping
    );

    // Return the modified image as bytes (no file creation)
    // return Uint8List.fromList(img.encodeJpg(image));
    final file = await File(imageFile).writeAsBytes(img.encodeJpg(image));
    return file.path;
  }

  // Future<File> addTextToImage(File imageFile, String text, String name) async {
  //   // Load the image
  //   final imageBytes = await imageFile.readAsBytes();
  //   img.Image? image = img.decodeImage(imageBytes);

  //   if (image == null) {
  //     throw Exception("Failed to decode image");
  //   }

  //   // Draw text on the image
  //   img.drawString(
  //     image,
  //     text,
  //     font: img.arial24, // Use built-in Arial font (24px)
  //     x: 10, // X position
  //     y: 10, // Y position
  //     // color: Color.fromARGB((255, 255, 255,0), // White text
  //     wrap: true, // Enable text wrapping
  //   );

  //   // Save the modified image
  //  // final directory = await getTemporaryDirectory();
  //    final directory =
  //       "${await _getExternalStoragePath()}/${DateTime.now().millisecondsSinceEpoch}_${userId}_${name}_${DateTime.now().millisecondsSinceEpoch}.jpg";
  //   // final newPath =
  //   //     '${directory.path}/${userId}_${name}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //   final modifiedImageFile = File(directory);
  //   await modifiedImageFile.writeAsBytes(img.encodeJpg(image));
  //   return modifiedImageFile;
  // }


  // Future<File> addTextToImagex(
  //     XFile imageFile, String text, String name) async {
  //   // Load the image
  //   final imageBytes = await imageFile.readAsBytes();
  //   img.Image? image = img.decodeImage(imageBytes);

  //   if (image == null) {
  //     throw Exception("Failed to decode image");
  //   }

  //   // Draw text on the image
  //   img.drawString(
  //     image,
  //     text,
  //     font: img.arial24, // Use built-in Arial font (24px)
  //     x: 10, // X position
  //     y: 10, // Y position
  //     // color: Color.fromARGB((255, 255, 255,0), // White text
  //     wrap: true, // Enable text wrapping
  //   );

  //   // Save the modified image
  //   final directory = await getTemporaryDirectory();
  //   final newPath =
  //       '${directory.path}/${userId}_${name}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //   final modifiedImageFile = File(newPath);

  //   await modifiedImageFile.writeAsBytes(img.encodeJpg(image));
  //   return modifiedImageFile;
  // }

  Future<String> name() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return '';
  }

  Future<String> deviceId() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      return iosInfo.identifierForVendor ?? '';
    }
    if (kIsWeb) {
      WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
      return webInfo.userAgent ?? '';
    }
    return '';
  }

  Future<String> deviceBrand() async {
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.brand;
    }
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.utsname.machine;
    }
    return '';
  }

  Future<String> deviceModelName() async {
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.model;
    }
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.model;
    }
    return await name();
  }

  String get platformName {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  /// Stable fingerprint for device binding (server should recompute from raw fields).
  Future<String> deviceFingerprint({
    required String deviceUniqueId,
    required String brand,
    required String model,
    required String appBundleId,
  }) async {
    final raw = '$deviceUniqueId|$brand|$model|$appBundleId';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  /// Full device payload for login and re-registration APIs.
  Future<DeviceAuthPayload> collectAuthDeviceInfo() async {
    final uniqueId = await deviceId();
    final brand = await deviceBrand();
    final model = await deviceModelName();
    final displayName = await name();
    final os = await deviceOs();
    final packageInfo = await PackageInfo.fromPlatform();
    final fingerprint = await deviceFingerprint(
      deviceUniqueId: uniqueId,
      brand: brand,
      model: model,
      appBundleId: packageInfo.packageName,
    );

    return DeviceAuthPayload(
      platform: platformName,
      deviceUniqueId: uniqueId,
      deviceFingerprint: fingerprint,
      deviceModel: model,
      deviceBrand: brand,
      deviceName: displayName,
      osVersion: os,
      appVersion: packageInfo.version,
    );
  }

  String get plaform {
    return "mobile";
  }

  Future<String> deviceOs() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.release;
    }

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      return iosInfo.systemVersion;
    }
    return '';
  }

  Future<Position> userPosition(
      {LocationAccuracy desiredAccuracy = LocationAccuracy.best}) async {
    final issue = await locationAvailabilityIssue();
    if (issue != null) {
      return Future.error(issue);
    }
    return Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: desiredAccuracy),
    );
  }

  /// A stricter variant of [userPosition] intended for sensitive flows
  /// (duty start/end, mark-in/out, submissions).
  ///
  /// Throws [LocationSpoofingException] (or other exceptions) when location
  /// signals look suspicious.
  Future<Position> secureUserPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
    int maxFixAgeSeconds = 90,
    double maxSpeedMps = 80, // ~288 km/h
    double maxJumpMeters = 5000,
    int minJumpWindowSeconds = 60,
  }) async {
    if (await isDeveloperOptionsEnabledCached()) {
      throw LocationSpoofingException(
          'Developer options are enabled. Please disable Developer options to continue.');
    }

    final pos = await userPosition(desiredAccuracy: desiredAccuracy);
    final reason = commitSecurePositionIfValid(
      pos,
      DateTime.now(),
      maxFixAgeSeconds: maxFixAgeSeconds,
      maxSpeedMps: maxSpeedMps,
      maxJumpMeters: maxJumpMeters,
      minJumpWindowSeconds: minJumpWindowSeconds,
    );
    if (reason != null) {
      throw LocationSpoofingException(reason);
    }
    return pos;
  }
}
