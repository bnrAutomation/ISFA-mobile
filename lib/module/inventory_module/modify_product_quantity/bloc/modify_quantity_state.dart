part of 'modify_quantity_bloc.dart';

@immutable
abstract class ModifyQuantityState {}

class LoadingState extends ModifyQuantityState {}

class LoadedState extends ModifyQuantityState {}

class ToastMessageState extends ModifyQuantityState {
  final String message;

  ToastMessageState(this.message);
}

class SuccessQtyChange extends ModifyQuantityState {}
