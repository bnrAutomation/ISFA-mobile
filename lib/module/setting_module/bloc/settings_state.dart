part of 'settings_bloc.dart';

@immutable
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class LoadingSettingState extends SettingsState {}

class SnackBarMessageSettingsState extends SettingsState {
  final String message;

  SnackBarMessageSettingsState(this.message);
}
