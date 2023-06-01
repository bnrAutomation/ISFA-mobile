part of 'set_pin_bloc.dart';

@immutable
abstract class SetPinEvent {}

class MoveSetPinEvent extends SetPinEvent {
  final String pin;
  final String confirmPin;
  MoveSetPinEvent(this.pin, this.confirmPin);
}
