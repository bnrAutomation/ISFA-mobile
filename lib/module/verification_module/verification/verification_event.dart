part of 'verification_bloc.dart';

@immutable
abstract class VerificationEvent {}

class VerificationTextChangeEvent extends VerificationEvent {
  final String otpValue;
  VerificationTextChangeEvent(this.otpValue);
}

class VerificationSubmitEvent extends VerificationEvent {
  final String verificationCode;
  VerificationSubmitEvent(this.verificationCode);
}

class ReSendPasswordEvent extends VerificationEvent {}
