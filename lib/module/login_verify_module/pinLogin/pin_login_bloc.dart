import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/login_verify_module/pin_login_repository.dart';
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
          emit(PinLoginLoadingState());
          final loginResponse = await repo.verifyPin(
              username: AppStorage().userDetail?.username.toString() ?? "",
              pin: event.pin);
          AppStorage().userDetail = loginResponse.logindata.userInfo;
          emit(LoginedSuccesfullState());
        } catch (err) {
          if (err.toString() == 'Please login instead') {
            emit(PinLoginTokenExpiredState());
          } else {
            debugPrint(err.toString());
            debugPrint("local saved pin is:- ${AppStorage().userDetail?.pin}");
            emit(PinLogInErrorState(err.toString()));
          }
        }
      }
    });
  }
}
