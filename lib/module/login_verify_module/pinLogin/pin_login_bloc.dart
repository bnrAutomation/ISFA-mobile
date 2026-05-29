import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/login_verify_module/pin_login_repository.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/device_auth_exception.dart';
import 'package:i_densfa/utility/device_auth_session.dart';
import 'package:i_densfa/utility/handler.dart' show resetHttpAuthGuards;

part 'pin_login_event.dart';
part 'pin_login_state.dart';

class PinLoginBloc extends Bloc<PinLoginEvent, PinLoginState> {
  PinLoginRepository repo;
  PinLoginBloc(this.repo) : super(PinLoginInitial()) {
    on<PinLoginEvent>((event, emit) {});
    on<VerifyPinEvent>((event, emit) async {
      if (event.pin.isEmpty) {
        emit(PinLogInErrorState("Pin is empty"));
      } else {
        try {
          emit(PinLoginLoadingState());
          final loginResponse = await repo.verifyPin(
              username: AppStorage().userDetail?.username.toString() ?? "",
              pin: event.pin);
          resetHttpAuthGuards();
          AppStorage().authToken = loginResponse.accessToken;
          await DeviceAuthSession.persistCurrentDevice();
          final logindata =
              await repo.getUserDetails(loginResponse.getUserId());
          AppStorage().userDetail = logindata.data;
          emit(LoginedSuccesfullState());
        } on DeviceAuthException catch (err) {
          emit(PinLoginDeviceUnauthorizedState(
            username:
                AppStorage().userDetail?.username.toString() ?? '',
            message: err.message,
          ));
        } catch (err) {
          if (err is ClientException || err is SocketException) {
            emit(PinLogInErrorState(
                "Network issue: This is due to network fluctuation or low internet speed."));
          } else {
            if (err.toString() == 'Please login instead') {
              emit(PinLoginTokenExpiredState());
            } else {
              emit(PinLogInErrorState(err.toString()));
            }
          }
        }
      }
    });
  }
}
