part of 'change_password_bloc.dart';

@immutable
abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ShowOldPasswordState extends ChangePasswordState {
  final bool isShowingOldPassword;
  ShowOldPasswordState(this.isShowingOldPassword);
}

class ShowNewPasswordState extends ChangePasswordState {
  final bool isShowingNewPassword;
  ShowNewPasswordState(this.isShowingNewPassword);
}

class ChangePasswordErrorState extends ChangePasswordState {
  final String errorMessage;
  ChangePasswordErrorState(this.errorMessage);
}

class ChangePasswordSuccesfullState extends ChangePasswordState {}

class ChangePasswordLoadingState extends ChangePasswordState {}
