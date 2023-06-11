part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class ChangeImageSettingsEvent extends SettingsEvent {
  final XFile imageFile;

  ChangeImageSettingsEvent(this.imageFile);
}

class ChangeEmailSettingsEvent extends SettingsEvent {
  final String email;

  ChangeEmailSettingsEvent(this.email);
}

class ChangePhoneSettingsEvent extends SettingsEvent {
  final String phone;

  ChangePhoneSettingsEvent(this.phone);
}
