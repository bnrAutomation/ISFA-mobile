/// Device metadata sent with login and device-registration requests.
class DeviceAuthPayload {
  final String platform;
  final String deviceUniqueId;
  final String deviceFingerprint;
  final String deviceModel;
  final String deviceBrand;
  final String deviceName;
  final String osVersion;
  final String appVersion;
  final String? firebaseInstallationId;
  final String? imei;

  const DeviceAuthPayload({
    required this.platform,
    required this.deviceUniqueId,
    required this.deviceFingerprint,
    required this.deviceModel,
    required this.deviceBrand,
    required this.deviceName,
    required this.osVersion,
    required this.appVersion,
    this.firebaseInstallationId,
    this.imei,
  });

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'deviceUniqueId': deviceUniqueId,
        'deviceFingerprint': deviceFingerprint,
        'deviceModel': deviceModel,
        'deviceBrand': deviceBrand,
        'deviceName': deviceName,
        'osVersion': osVersion,
        'appVersion': appVersion,
        if (firebaseInstallationId != null)
          'firebaseInstallationId': firebaseInstallationId,
        if (imei != null && imei!.isNotEmpty) 'imei': imei,
      };
}

/// Response after submitting a device re-registration request.
class DeviceRegistrationRequestResponse {
  final String requestId;
  final String status;
  final String message;

  DeviceRegistrationRequestResponse({
    required this.requestId,
    required this.status,
    required this.message,
  });

  factory DeviceRegistrationRequestResponse.fromJson(
      Map<String, dynamic> json) {
    return DeviceRegistrationRequestResponse(
      requestId: json['requestId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      message: json['message']?.toString() ?? '',
    );
  }
}
