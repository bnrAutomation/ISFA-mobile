import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/login_set_pin_module/set_pin_repository.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/module/login_module/models/auth_model.dart';

part 'set_pin_event.dart';
part 'set_pin_state.dart';

class SetPinBloc extends Bloc<SetPinEvent, SetPinState> {
  SetPinRepository repo;
  SetPinBloc(this.repo) : super(SetPinInitial()) {
    on<SetPinEvent>((event, emit) {});
    on<MoveSetPinEvent>((event, emit) async {
      if (event.pin.isEmpty) {
        emit(SetPinErrorState("Pin is empty"));
      } else if (event.pin.length != 4) {
        emit(SetPinErrorState("Pin length should be 4 characters"));
      } else if (event.confirmPin.isEmpty) {
        emit(SetPinErrorState("Confirm pin is empty"));
      } else if (event.pin != event.confirmPin) {
        emit(SetPinErrorState("Given Pin not matched."));
      } else {
        emit(InprogressSetPinState());
        try {
          final setPinResponse = await repo.setPin(
              username: AppStorage().userDetail?.email.toString() ?? "",
              pin: event.pin);
          if (setPinResponse && AppStorage().userDetail?.role != "admin") {
            UserInfo userdetail = AppStorage().userDetail!;
            userdetail.pin = event.pin;
            AppStorage().userDetail = userdetail;
            emit(SetPinedSuccesfullState());
          } else {
            emit(SetPinErrorState("User doesn't exist."));
          }
        } catch (err) {
          emit(SetPinErrorState(err.toString()));
        }
      }
    });
  }
}
