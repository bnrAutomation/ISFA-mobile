part of 'device_registration_bloc.dart';

@immutable
abstract class DeviceRegistrationState {}

class DeviceRegistrationInitial extends DeviceRegistrationState {}

class DeviceRegistrationLoading extends DeviceRegistrationState {}

class DeviceRegistrationSuccess extends DeviceRegistrationState {
  final String requestId;
  final String message;

  DeviceRegistrationSuccess({
    required this.requestId,
    required this.message,
  });
}

class DeviceRegistrationStatusLoaded extends DeviceRegistrationState {
  final String status;
  final String message;

  DeviceRegistrationStatusLoaded({
    required this.status,
    required this.message,
  });
}

class DeviceRegistrationError extends DeviceRegistrationState {
  final String message;

  DeviceRegistrationError(this.message);
}
