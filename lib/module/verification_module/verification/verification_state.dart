part of 'verification_bloc.dart';

@immutable
abstract class VerificationState {}

class VerificationInitial extends VerificationState {}

class VerificationErrorState extends VerificationState {
  final String errorMessage;
  VerificationErrorState(this.errorMessage);
}

class VerificationValidState extends VerificationState {}

class VerificationSuccesfullState extends VerificationState {}

class VerificationCodeResend extends VerificationState {}
