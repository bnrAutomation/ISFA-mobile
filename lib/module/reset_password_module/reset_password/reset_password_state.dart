part of 'reset_password_bloc.dart';

@immutable
abstract class ResetPasswordState {}

class ResetPasswordValidState extends ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ShowNewPasswordState extends ResetPasswordState {
  final bool visible;
  ShowNewPasswordState(this.visible);
}

class ShowConfirmPasswordState extends ResetPasswordState {
  final bool visible;
  ShowConfirmPasswordState(this.visible);
}

class ResetPasswordErrorState extends ResetPasswordState {
  final String errorMessage;
  ResetPasswordErrorState(this.errorMessage);
}

class ResetPasswordSuccesfullState extends ResetPasswordState {}
