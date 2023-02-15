part of 'verification_bloc.dart';

@immutable
abstract class VerificationEvent {}

class VerificationTextChangeEvent extends VerificationEvent {
  final String otpValue;
  VerificationTextChangeEvent(this.otpValue);
}

class VerificationSubmitEvent extends VerificationEvent {
  final String otp;
  VerificationSubmitEvent(this.otp);
}

class ReSendPasswordEvent extends VerificationEvent {}
