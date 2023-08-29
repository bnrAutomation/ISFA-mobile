part of 'pin_login_bloc.dart';

@immutable
abstract class PinLoginState {}

class PinLoginInitial extends PinLoginState {}

class PinLogInErrorState extends PinLoginState {
  final String message;
  PinLogInErrorState(this.message);
}

class LoginedSuccesfullState extends PinLoginState {}

class PinLoginLoadingState extends PinLoginState {}

class PinLoginTokenExpiredState extends PinLoginState {}
