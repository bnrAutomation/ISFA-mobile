part of 'device_registration_bloc.dart';

@immutable
abstract class DeviceRegistrationEvent {}

class DeviceRegistrationSubmitEvent extends DeviceRegistrationEvent {
  final String username;
  final String password;
  final String reason;

  DeviceRegistrationSubmitEvent({
    required this.username,
    required this.password,
    required this.reason,
  });
}

class DeviceRegistrationCheckStatusEvent extends DeviceRegistrationEvent {
  final String username;

  DeviceRegistrationCheckStatusEvent(this.username);
}
