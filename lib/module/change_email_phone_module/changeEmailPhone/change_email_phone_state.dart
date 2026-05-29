part of 'change_email_phone_bloc.dart';

@immutable
abstract class ChangeEmailPhoneState {}

class ChangeEmailPhoneInitial extends ChangeEmailPhoneState {}

class ChangeEmailPhoneErrorState extends ChangeEmailPhoneState {
  final String errorMessage;
  ChangeEmailPhoneErrorState(this.errorMessage);
}
