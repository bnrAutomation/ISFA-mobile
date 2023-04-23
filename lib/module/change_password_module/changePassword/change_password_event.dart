part of 'change_password_bloc.dart';

@immutable
abstract class ChangePasswordEvent {}

class OldPasswordButtonEvent extends ChangePasswordEvent {}

class NewPasswordButtonEvent extends ChangePasswordEvent {}

class SubmitChangePasswordEvent extends ChangePasswordEvent {
  final String newPassword;
  final String oldPassword;

  SubmitChangePasswordEvent(this.newPassword, this.oldPassword);
}
