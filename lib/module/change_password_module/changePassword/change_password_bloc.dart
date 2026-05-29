import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/change_password_module/change_password_repository.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordRepository repo;
  bool isShowingNewPassword = false;
  bool isShowingOldPassword = false;

  String newPassword = "";
  String oldPassword = "";
  ChangePasswordBloc(this.repo) : super(ChangePasswordInitial()) {
    on<OldPasswordButtonEvent>((event, emit) {
      isShowingOldPassword = !isShowingOldPassword;
      emit(ShowOldPasswordState(isShowingOldPassword));
    });
    on<NewPasswordButtonEvent>((event, emit) {
      isShowingNewPassword = !isShowingNewPassword;
      emit(ShowNewPasswordState(isShowingNewPassword));
    });
    on<SubmitChangePasswordEvent>((event, emit) async {
      if (event.newPassword.isEmpty || event.oldPassword.isEmpty) {
        emit(ChangePasswordErrorState("The field should not be empty."));
      }
      //  else if (event.oldPassword.trim().isNotEmpty
      //     // &&
      //     //     !event.oldPassword.trim().passwordValid()
      //     ) {
      //   emit(ChangePasswordErrorState(
      //       "Old Password should be minimum 16 characters and at least one uppercase letter, one lowercase letter, one number and one special character"));
      // }
      else if (event.newPassword.trim().isNotEmpty &&
          !event.newPassword.trim().passwordValid()) {
        emit(ChangePasswordErrorState(
            "New Password should be a minimum of 16 characters and at least one uppercase letter, one lowercase letter, one number, and one special character allowed are:@\$!%*?&="));
      } else if (event.newPassword == event.oldPassword) {
        emit(ChangePasswordErrorState(
            "New password should not match with old password."));
      } else {
        try {
          emit(ChangePasswordLoadingState());
          await repo.changePassword(
              oldPassword: event.oldPassword, newPassword: event.newPassword);
          final logindata =
              await repo.getUserDetails(AppStorage().userDetail?.id);

          AppStorage().userDetail = logindata.data;
          emit(ChangePasswordSuccesfullState());
          AppStorage().userDetail?.resetpass = true;
        } catch (err) {
          emit(ChangePasswordErrorState(err.toString()));
        }
      }
    });
  }
}
