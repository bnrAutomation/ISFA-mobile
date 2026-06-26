import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/credential_storage.dart';
import 'package:i_densfa/utility/device_auth_exception.dart';
import 'package:i_densfa/utility/device_auth_session.dart';
import 'package:i_densfa/utility/handler.dart' show resetHttpAuthGuards;

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
      }
      else if (event.password.trim().isEmpty) {
        emit(LogInErrorState("Password is empty"));
      }
      // else if (!event.password.trim().passwordValid()) {
      //   emit(LogInErrorState("Password should be minimum 16 characters and at least one uppercase letter, one lowercase letter, one number and one special character"));
      // }
      else {
        try {
          emit(LogInLoadingState());
          final loginResponse = await repo.login(
              username: event.username.trim(), password: event.password.trim());
          resetHttpAuthGuards();
          AppStorage().authToken = loginResponse.accessToken;
          await DeviceAuthSession.persistCurrentDevice();
          final logindata =
              await repo.getUserDetails(loginResponse.getUserId());
          if (logindata.data.role != "admin") {
            AppStorage().userDetail = logindata.data;
            await CredentialStorage.persist(
              remember: event.rememberMe,
              username: event.username.trim(),
              password: event.password.trim(),
            );
            if (logindata.data.pin.length == 4 &&
                (int.tryParse(logindata.data.pin) ?? -1) >= 0) {
              emit(LoginedSuccesfullState());
            } else {
              emit(MoveToSetPinState());
            }
          } else {
            emit(LogInErrorState("User doesn't exist."));
          }
        } on DeviceAuthException catch (err) {
          emit(LoginDeviceUnauthorizedState(
            username: event.username.trim(),
            message: err.message,
          ));
        } catch (err) {
          if (err is ClientException || err is SocketException) {
            emit(LogInErrorState(
                "Network issue: This is due to network fluctuation or low internet speed."));
          } else {
            emit(LogInErrorState(err.toString()));
          }
        }
      }
    });
  }
}
