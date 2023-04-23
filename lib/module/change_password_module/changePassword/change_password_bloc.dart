import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/change_password_module/change_password_repository.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordRepository repo;
  bool isShowingNewPassword = false;
  bool isShowingOldPassword = false;
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
        emit(ChangePasswordErrorState("Feild should not be empty."));
      } else if (event.newPassword == event.oldPassword) {
        emit(ChangePasswordErrorState(
            "New password is not match with old password."));
      } else {
        try {
          emit(ChangePasswordLoadingState());
          await repo.changePassword(
              oldPassword: event.oldPassword, newPassword: event.newPassword);

          emit(ChangePasswordSuccesfullState());
        } catch (err) {
          emit(ChangePasswordErrorState(err.toString()));
        }
      }
    });
  }
}
