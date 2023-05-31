part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginTextChangeEvent extends LoginEvent {
  final String userValue;
  final String passwordValue;
  LoginTextChangeEvent(this.userValue, this.passwordValue);
}

class LoginSubmitEvent extends LoginEvent {
  final String username;
  final String password;
  LoginSubmitEvent(this.username, this.password);
}

class LoginShowPasswordButtonEvent extends LoginEvent {}

class SetPinEvent extends LoginEvent {
  final String pin;
  final String confirmPin;
  SetPinEvent(this.pin, this.confirmPin);
}
