part of 'tabbar_bloc.dart';

@immutable
abstract class TabbarEvent {}

class ChangeTabEvent extends TabbarEvent {
  final int selectIndex;
  ChangeTabEvent(this.selectIndex);
}

class EndDutyStatusTabbarEvent extends TabbarEvent {
  final XFile? file;
  final BuildContext context;
  EndDutyStatusTabbarEvent(this.file, this.context);
}

class StartDutyStatusTabbarEvent extends TabbarEvent {
  final XFile? file;
  final BuildContext context;
  StartDutyStatusTabbarEvent(this.file, this.context);
}

class UpdateSideMenuDetailsEvent extends TabbarEvent {}

class SubmitToken extends TabbarEvent {}

class LogoutEvent extends TabbarEvent {}

class ShowSectionPopUp extends TabbarEvent {
  final String title;
  final String message;
  ShowSectionPopUp(this.title, this.message);
}

class ResetPassword extends TabbarEvent {}
