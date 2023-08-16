part of 'tabbar_bloc.dart';

@immutable
abstract class TabberState {}

class TabberInitial extends TabberState {}

class UpdateIndexState extends TabberState {
  final int index;
  UpdateIndexState(this.index);
}

class OnlineSwitchLoadingTabberState extends TabberState {}

class OnlineStatusUpdateState extends TabberState {}

class TabbarSnackBarMessageState extends TabberState {
  final String message;

  TabbarSnackBarMessageState(this.message);
}
