part of 'tabber_bloc.dart';

@immutable
abstract class TabberEvent {}

class ChangeTabEvent extends TabberEvent {
  final int selectIndex;
  ChangeTabEvent(this.selectIndex);
}

class UpdateOnlineStatusEvent extends TabberEvent {
  final bool updatedStatus;

  UpdateOnlineStatusEvent(this.updatedStatus);
}

class UpdateSideMenuDetailsEvent extends TabberEvent {}
