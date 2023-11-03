import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/reset_password_module/reset_password_repository.dart';
import 'package:i_densfa/utility/extensions.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  bool isShowingNewPassword = true;
  bool isShowingConfirmPassword = true;
  final ResetPasswordRepository repo;
  ResetPasswordBloc(this.repo) : super(ResetPasswordInitial()) {
    on<NewPasswordButtonEvent>((event, emit) {
      isShowingNewPassword = !isShowingNewPassword;
      emit(ShowNewPasswordState(isShowingNewPassword));
    });
    on<ConfirmPasswordButtonEvent>((event, emit) {
      isShowingConfirmPassword = !isShowingConfirmPassword;
      emit(ShowConfirmPasswordState(isShowingConfirmPassword));
    });

    on<SubmitChangePasswordEvent>((event, emit) async {
      if (event.newPassword.isEmpty || event.confirmassword.isEmpty) {
        emit(ResetPasswordErrorState("The field should not be empty."));
      } else if (event.newPassword.trim().isNotEmpty &&
          !event.newPassword.trim().passwordValid()) {
        emit(ResetPasswordErrorState(
            "New Password should be minimum eight characters and at least one uppercase letter, one lowercase letter, one number and one special character"));
      } else if (event.newPassword != event.confirmassword) {
        emit(ResetPasswordErrorState(
            "The new password doesn't match with Confirm password."));
      } else {
        try {
          emit(ResetPasswordLoadingState());
          final verificationResponse = await repo.resetPassword(
              username: event.email,
              otp: event.otp,
              password: event.newPassword);
          debugPrint(verificationResponse.message);

          emit(ResetPasswordSuccesfullState());
        } catch (err) {
          emit(ResetPasswordErrorState(err.toString()));
        }
      }
    });
  }
}
