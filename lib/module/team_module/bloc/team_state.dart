part of 'team_bloc.dart';

@immutable
abstract class TeamState {}

class TeamInitial extends TeamState {}

class ViewStyleChangedTeamState extends TeamState {}

class SnackbarMessageTeamState extends TeamState {
  final String message;

  SnackbarMessageTeamState(this.message);
}

class TeamDataUpdatedTeamState extends TeamState {}

class NotificationSentSuccessTeamState extends TeamState {}
