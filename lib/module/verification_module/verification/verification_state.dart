part of 'verification_bloc.dart';

@immutable
abstract class VerificationState {}

class VerificationInitial extends VerificationState {}

class VerificationErrorState extends VerificationState {
  final String errorMessage;
  VerificationErrorState(this.errorMessage);
}

class VerificationSuccesfullState extends VerificationState {
  final String email;
  final String otp;
  VerificationSuccesfullState(this.email, this.otp);
}

class VerificationValidState extends VerificationState {}

class VerificationCodeResend extends VerificationState {}

class VerificationLoadingState extends VerificationState {}
