import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'verification_event.dart';
part 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc() : super(VerificationInitial()) {
    on<VerificationEvent>((event, emit) {
      if (event is VerificationTextChangeEvent) {
        if (event.otpValue.isEmpty || event.otpValue.length != 6) {
          emit(VerificationErrorState("Please Enter Valid OTP"));
        } else {
          emit(VerificationValidState());
        }
      } else if (event is VerificationSubmitEvent) {
        if (event.otp.isEmpty || event.otp.length != 6) {
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
