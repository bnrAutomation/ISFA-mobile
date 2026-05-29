import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_helper.dart';

/// Persists and attaches registered-device headers for authenticated API calls.
class DeviceAuthSession {
  DeviceAuthSession._();

  /// Call after successful login so [apiHeaders] can be sent on every request.
  static Future<void> persistCurrentDevice() async {
    final device = await Device().collectAuthDeviceInfo();
    final storage = AppStorage();
    storage.registeredDeviceFingerprint = device.deviceFingerprint;
    storage.registeredDeviceUniqueId = device.deviceUniqueId;
    storage.registeredDevicePlatform = device.platform;
  }

  static Map<String, String> apiHeaders() {
    final fingerprint = AppStorage().registeredDeviceFingerprint;
    final uniqueId = AppStorage().registeredDeviceUniqueId;
    if (fingerprint == null || fingerprint.isEmpty) return {};
    return {
      if (uniqueId != null && uniqueId.isNotEmpty) 'Device-Id': uniqueId,
      'X-Device-Fingerprint': fingerprint,
    };
  }

  static void clear() {
    final storage = AppStorage();
    storage.registeredDeviceFingerprint = null;
    storage.registeredDeviceUniqueId = null;
    storage.registeredDevicePlatform = null;
  }
}
