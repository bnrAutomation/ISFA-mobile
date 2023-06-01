part of 'set_pin_bloc.dart';

@immutable
abstract class SetPinState {}

class SetPinInitial extends SetPinState {}

class SetPinErrorState extends SetPinState {
  final String errorMessage;
  SetPinErrorState(this.errorMessage);
}

class SetPinedSuccesfullState extends SetPinState {}
