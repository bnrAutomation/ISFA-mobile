import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  bool isShowingNewPassword = true;
  bool isShowingConfirmPassword = true;
  ResetPasswordBloc() : super(ResetPasswordInitial()) {
    on<ResetPasswordEvent>((event, emit) {
      if (event is NewPasswordButtonEvent) {
        isShowingNewPassword = !isShowingNewPassword;
        emit(ShowNewPasswordState(isShowingNewPassword));
      } else if (event is ConfirmPasswordButtonEvent) {
        isShowingConfirmPassword = !isShowingConfirmPassword;
        emit(ShowConfirmPasswordState(isShowingConfirmPassword));
      } else if (event is ChangePassword) {
        if (event.newPasswordValue.isEmpty ||
            event.confirmasswordValue.isEmpty) {
          emit(ResetPasswordErrorState("Feild should not be empty."));
        } else if (event.newPasswordValue != event.confirmasswordValue) {
          emit(ResetPasswordErrorState(
              "Confirm password is not match with new password."));
        } else {
          emit(ResetPasswordValidState());
        }
      } else if (event is SubmitChangePasswordEvent) {
        if (event.newPassword.isEmpty || event.confirmassword.isEmpty) {
          emit(ResetPasswordErrorState("Feild should not be empty."));
        } else if (event.newPassword != event.confirmassword) {
          emit(ResetPasswordErrorState(
              "Confirm password is not match with new password."));
        } else {
          emit(ResetPasswordSuccesfullState());
        }
      }
    });
  }
}
