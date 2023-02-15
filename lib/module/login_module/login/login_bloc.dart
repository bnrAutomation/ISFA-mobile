import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  bool isShowingPassword = false;

  LoginBloc() : super(LoginInitialState()) {
    on<LoginEvent>((event, emit) {
      if (event is LoginShowPasswordButtonEvent) {
        isShowingPassword = !isShowingPassword;
        emit(LoginShowPasswordState(isShowingPassword));
      } else if (event is LoginTextChangeEvent) {
        if (event.userValue.isEmpty || event.passwordValue.isEmpty) {
          emit(LogInErrorState("Invalid Username & Password"));
        } else {
          emit(LogInValidState());
        }
      } else if (event is LoginSubmitEvent) {
        if (event.username.isEmpty || event.password.isEmpty) {
          emit(LogInErrorState("Invalid Username & Password"));
        } else {
          emit(LoginedSuccesfullState());
        }
      }
    });
  }
}
