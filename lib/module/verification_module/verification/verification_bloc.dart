import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'verification_event.dart';
part 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  var varificationCode = "";
  VerificationBloc() : super(VerificationInitial()) {
    on<VerificationEvent>((event, emit) {
      if (event is VerificationTextChangeEvent) {
        if (event.otpValue.length == 6) {
          // emit(VerificationErrorState("Please Enter Valid OTP"));
        } else {
          varificationCode = event.otpValue;
          emit(VerificationValidState());
        }
      } else if (event is VerificationSubmitEvent) {
        if (varificationCode.isEmpty || varificationCode.length != 6) {
          emit(VerificationErrorState("Please Enter Valid OTP"));
        } else {
          emit(VerificationSuccesfullState());
        }
      } else if (event is ReSendPasswordEvent) {
        emit(VerificationCodeResend());
      }
    });
  }
}
