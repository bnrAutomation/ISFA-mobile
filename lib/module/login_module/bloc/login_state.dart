part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LogInInvalidState extends LoginState {}

class LogInValidState extends LoginState {}

class LogInErrorState extends LoginState {
  final String errorMessage;
  LogInErrorState(this.errorMessage);
}

class LogInLoadingState extends LoginState {}

class LoginShowPasswordState extends LoginState {
  final bool visible;
  LoginShowPasswordState(this.visible);
}

class LoginedSuccesfullState extends LoginState {}

class MoveToSetPinState extends LoginState {}
