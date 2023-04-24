import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/verification_module/verification_repository.dart';

part 'verification_event.dart';
part 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  var varificationCode = "";
  final VerificationRepository repo;
  VerificationBloc(this.repo) : super(VerificationInitial()) {
    on<VerificationErrorEvent>((event, emit) {
      emit(VerificationErrorState(event.msg));
    });
    on<VerificationTextChangeEvent>((event, emit) {
      if (event.otpValue.length != 4) {
        varificationCode = event.otpValue;
        emit(VerificationErrorState("Please Enter Valid OTP"));
      } else {
        varificationCode = event.otpValue;
        emit(VerificationValidState());
      }
    });
    on<ReSendPasswordEvent>((event, emit) {
      emit(VerificationCodeResend());
    });

    on<VerificationSubmitEvent>((event, emit) async {
      if (varificationCode.isEmpty || varificationCode.length != 4) {
        emit(VerificationErrorState("Please Enter Valid OTP"));
      } else {
        try {
          emit(VerificationLoadingState());
          final verificationResponse = await repo.verifiOTP(
              username: event.username, otp: varificationCode);
          debugPrint(verificationResponse.toString());
          emit(VerificationSuccesfullState(event.username, varificationCode));
        } catch (err) {
          emit(VerificationErrorState(err.toString()));
        }
      }
    });
  }
}
