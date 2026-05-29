import 'package:i_densfa/utility/models/device_auth_payload.dart';

/// Headers sent with authenticate requests for backward-compatible backends.
Map<String, String> loginDeviceHeaders(DeviceAuthPayload device) => {
      'Content-Type': 'application/json',
      'User-Agent': device.deviceName,
      'Device-Id': device.deviceUniqueId,
      'X-Device-Fingerprint': device.deviceFingerprint,
    };
