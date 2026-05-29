/// Thrown when login is rejected because the device is not registered for the user.
class DeviceAuthException implements Exception {
  static const String deviceNotAuthorizedCode = 'DEVICE_NOT_AUTHORIZED';

  final String code;
  final String message;

  const DeviceAuthException({
    required this.code,
    required this.message,
  });

  bool get isDeviceNotAuthorized => code == deviceNotAuthorizedCode;

  @override
  String toString() => message;
}
