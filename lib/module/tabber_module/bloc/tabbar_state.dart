part of 'tabbar_bloc.dart';

@immutable
abstract class TabbarState {}

class TabbarInitial extends TabbarState {}

class UpdateIndexState extends TabbarState {
  final int index;
  UpdateIndexState(this.index);
}

class TabbarShowProgressHudState extends TabbarState {}

class OnlineStatusUpdateState extends TabbarState {}

class TabbarSnackBarMessageState extends TabbarState {
  final String message;

  TabbarSnackBarMessageState(this.message);
}

class LogoutSuccessfulState extends TabbarState {}

class ShowSectionPopUpState extends TabbarState {
  final String title;
  final String message;
  ShowSectionPopUpState(this.title, this.message);
}

class ResetPasswordState extends TabbarState {}
