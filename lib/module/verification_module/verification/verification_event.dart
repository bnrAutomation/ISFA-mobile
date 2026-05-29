part of 'verification_bloc.dart';

@immutable
abstract class VerificationEvent {}

class VerificationTextChangeEvent extends VerificationEvent {
  final String otpValue;
  final String username;
  VerificationTextChangeEvent(this.otpValue, this.username);
}

class VerificationSubmitEvent extends VerificationEvent {
  final String verificationCode;
  final String username;
  VerificationSubmitEvent(this.verificationCode, this.username);
}

class ReSendPasswordEvent extends VerificationEvent {
  final String email;
  ReSendPasswordEvent(this.email);
}

class VerificationErrorEvent extends VerificationEvent {
  final String msg;
  VerificationErrorEvent(this.msg);
}
