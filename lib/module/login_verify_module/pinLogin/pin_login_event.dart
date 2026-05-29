part of 'pin_login_bloc.dart';

@immutable
abstract class PinLoginEvent {}

class VerifyPinEvent extends PinLoginEvent {
  final String pin;
  VerifyPinEvent(this.pin);
}
