part of 'tabber_bloc.dart';

@immutable
abstract class TabberEvent {}

class ChangeTabEvent extends TabberEvent {
  final int selectIndex;
  ChangeTabEvent(this.selectIndex);
}

class EndDutyStatusTabberEvent extends TabberEvent {}

class StartDutyStatusTabberEvent extends TabberEvent {
  final XFile? file;

  StartDutyStatusTabberEvent(this.file);
}

class UpdateSideMenuDetailsEvent extends TabberEvent {}
