part of 'tabber_bloc.dart';

@immutable
abstract class TabberState {}

class TabberInitial extends TabberState {}

class UpdateIndexState extends TabberState {
  final int index;
  UpdateIndexState(this.index);
}

class OnlineStatusUpdateState extends TabberState {}

class TabbarSnackBarMessageState extends TabberState {
  final String message;

  TabbarSnackBarMessageState(this.message);
}
