import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/reset_password_module/reset_password_repository.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  bool isShowingNewPassword = true;
  bool isShowingConfirmPassword = true;
  final ResetPasswordRepository repo;
  ResetPasswordBloc(this.repo) : super(ResetPasswordInitial()) {
    on<NewPasswordButtonEvent>((event, emit) => {
          isShowingNewPassword = !isShowingNewPassword,
          emit(ShowNewPasswordState(isShowingNewPassword))
        });
    on<ConfirmPasswordButtonEvent>((event, emit) {
      isShowingConfirmPassword = !isShowingConfirmPassword;
      emit(ShowConfirmPasswordState(isShowingConfirmPassword));
    });
    on<ChangePassword>((event, emit) {
      if (event.newPasswordValue.isEmpty || event.confirmasswordValue.isEmpty) {
        emit(ResetPasswordErrorState("Feild should not be empty."));
      } else if (event.newPasswordValue != event.confirmasswordValue) {
        emit(ResetPasswordErrorState(
            "Confirm password is not match with new password."));
      } else {
        emit(ResetPasswordValidState());
      }
    });
    on<SubmitChangePasswordEvent>((event, emit) async {
      if (event.newPassword.isEmpty || event.confirmassword.isEmpty) {
        emit(ResetPasswordErrorState("Feild should not be empty."));
      } else if (event.newPassword != event.confirmassword) {
        emit(ResetPasswordErrorState(
            "Confirm password is not match with new password."));
      } else {
        try {
          emit(ResetPasswordLoadingState());
          final verificationResponse = await repo.resetPassword(
              username: event.email,
              otp: event.otp,
              password: event.newPassword);
          debugPrint(verificationResponse.toString());

          emit(ResetPasswordSuccesfullState());
        } catch (err) {
          emit(ResetPasswordErrorState(err.toString()));
        }
      }
    });
  }
}
