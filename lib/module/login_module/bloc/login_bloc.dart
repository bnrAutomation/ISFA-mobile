import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/utility/app_storage.dart';

import '../login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repo;
  bool isShowingPassword = false;

  LoginBloc(this.repo) : super(LoginInitialState()) {
    on<LoginShowPasswordButtonEvent>((event, emit) {
      isShowingPassword = !isShowingPassword;
      emit(LoginShowPasswordState(isShowingPassword));
    });
    on<LoginTextChangeEvent>((event, emit) {
      if (event.userValue.isEmpty) {
        emit(LogInErrorState("Username is empty"));
      } else if (event.passwordValue.isEmpty) {
        emit(LogInErrorState("Password is empty"));
      } else {
        emit(LogInValidState());
      }
    });
    on<LoginSubmitEvent>((event, emit) async {
      if (event.username.isEmpty) {
        emit(LogInErrorState("Username is empty"));
      } else if (event.password.trim().isEmpty) {
        emit(LogInErrorState("Password is empty"));
      }

      //  else if (!event.password.trim().passwordValid()) {
      //   emit(LogInErrorState(
      //       "Password should be minimum eight characters and at least one uppercase letter, one lowercase letter, one number and one special character"));
      // }

      else {
        try {
          emit(LogInLoadingState());
          final loginResponse = await repo.login(
              username: event.username.trim(), password: event.password.trim());

          AppStorage().authToken = loginResponse.accessToken;

          final logindata =
              await repo.getUserDetails(loginResponse.getUserId());
          if (logindata.data.role != "admin") {
            AppStorage().userDetail = logindata.data;
            if ((int.tryParse(logindata.data.pin) ?? 0) > 0) {
              emit(LoginedSuccesfullState());
            } else {
              emit(MoveToSetPinState());
            }
          } else {
            emit(LogInErrorState("User doesn't exist."));
          }
        } catch (err) {
          emit(LogInErrorState(err.toString()));
        }
      }
    });
  }
}
