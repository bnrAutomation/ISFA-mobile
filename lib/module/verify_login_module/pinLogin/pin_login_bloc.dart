import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/verify_login_module/pin_login_repository.dart';
import 'package:i_densfa/utility/app_storage.dart';

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
          final loginResponse = await repo.verifyPin(
              username: AppStorage().userDetail?.id.toString() ?? "",
              pin: event.pin);
          if (loginResponse.logindata.userInfo.iRole == "user") {
            AppStorage().userDetail = loginResponse.logindata.userInfo;
            emit(LoginedSuccesfullState());
          } else {
            emit(PinLogInErrorState("User doesn't exist."));
          }
        } catch (err) {
          emit(PinLogInErrorState(err.toString()));
        }
      }
    });
  }
}
