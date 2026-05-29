part of 'team_bloc.dart';

@immutable
abstract class TeamEvent {}

class ChangeViewStyleTeamEvent extends TeamEvent {
  final bool isHierarchyView;

  ChangeViewStyleTeamEvent(this.isHierarchyView);
}

class GetTeamMembersEvent extends TeamEvent {
  final int? userId;

  GetTeamMembersEvent({this.userId});
}

class SearchTeamEvent extends TeamEvent {
  final String searchText;

  SearchTeamEvent(this.searchText);
}

class GetTeamDataEvent extends TeamEvent {}

class GoUpperLevelTeamEvent extends TeamEvent {}

class SendNotificationTeamEvent extends TeamEvent {
  final String message;
  final int leadUserId;

  SendNotificationTeamEvent(this.message, this.leadUserId);
}
