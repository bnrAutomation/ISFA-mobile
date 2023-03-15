import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repo;
  bool isShowingPassword = false;

  LoginBloc(this.repo) : super(LoginInitialState()) {
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
      }
    });

    on(_handleLogin);
  }

  void _handleLogin(LoginSubmitEvent event, Emitter<LoginState> emit) async {
    if (event.username.isEmpty) {
      emit(LogInErrorState("Username is empty"));
    } else if (event.password.isEmpty) {
      emit(LogInErrorState("Password is empty"));
    } else if (event.password.length < 6) {
      emit(LogInErrorState("Short password"));
    } else {
      try {
        emit(LogInLoadingState());
        // final resp = await repo.userLogin(event.username, event.password);
        // debugPrint(resp.toString());
        emit(LoginedSuccesfullState());
      } catch (err) {
        emit(LogInErrorState(err.toString()));
      }
    }
  }
}
