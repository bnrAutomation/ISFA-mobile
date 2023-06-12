part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class ChangeImageSettingsEvent extends SettingsEvent {
  final XFile imageFile;

  ChangeImageSettingsEvent(this.imageFile);
}

class ChangeEmailPhoneSettingsEvent extends SettingsEvent {}
