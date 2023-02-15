part of 'reset_password_bloc.dart';

@immutable
abstract class ResetPasswordEvent {}

class NewPasswordButtonEvent extends ResetPasswordEvent {}

class ConfirmPasswordButtonEvent extends ResetPasswordEvent {}

class ChangePassword extends ResetPasswordEvent {
  final String newPasswordValue;
  final String confirmasswordValue;
  ChangePassword(this.newPasswordValue, this.confirmasswordValue);
}

class SubmitChangePasswordEvent extends ResetPasswordEvent {
  final String newPassword;
  final String confirmassword;
  SubmitChangePasswordEvent(this.newPassword, this.confirmassword);
}
