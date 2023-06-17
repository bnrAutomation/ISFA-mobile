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
      emit(LogInValidState());
    });
    on<LoginSubmitEvent>((event, emit) async {
      if (event.username.isEmpty) {
        emit(LogInErrorState("Username is empty"));
      } else if (event.password.isEmpty) {
        emit(LogInErrorState("Password is empty"));
      } else if (event.password.length < 6) {
        emit(LogInErrorState("Short password"));
      } else {
        try {
          emit(LogInLoadingState());
          final loginResponse = await repo
              .login(
                  username: event.username.trim(),
                  password: event.password.trim())
              .catchError((onError) {
            throw onError.toString();
          });
          if (loginResponse.logindata.userInfo.iRole == "user") {
            debugPrint(loginResponse.toString());
            AppStorage().userDetail = loginResponse.logindata.userInfo;
            if ((int.tryParse(loginResponse.logindata.userInfo.pin) ?? 0) > 0) {
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
