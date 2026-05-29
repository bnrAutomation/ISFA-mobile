part of 'forgot_password_bloc.dart';

@immutable
abstract class ForgotPasswordEvent {}

class OTPCallEvent extends ForgotPasswordEvent {}

class ChangeTextEvent extends ForgotPasswordEvent {
  final String useridValue;
  ChangeTextEvent(this.useridValue);
}

class ForgotPasswordSubmitEvent extends ForgotPasswordEvent {
  final String userid;
  ForgotPasswordSubmitEvent(this.userid);
}
