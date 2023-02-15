part of 'forgot_password_bloc.dart';

@immutable
abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordErrorState extends ForgotPasswordState {
  final String errorMessage;
  ForgotPasswordErrorState(this.errorMessage);
}

class ForgotPasswordValidState extends ForgotPasswordState {}

class ForgotPasswordSubmitState extends ForgotPasswordState {}

class ForgotPasswordSuccesfullState extends ForgotPasswordState {}
