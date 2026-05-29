part of 'issues_management_bloc.dart';

@immutable
sealed class IssuesManagementEvent {}

final class GetIssuesEvent extends IssuesManagementEvent {}

final class GetNextIssuesEvent extends IssuesManagementEvent {
  final int offset;
  GetNextIssuesEvent(this.offset);
}

final class DataChangeEvent extends IssuesManagementEvent {}

final class FromDateIssuesEvent extends IssuesManagementEvent {
  final DateTime dateTime;
  FromDateIssuesEvent(this.dateTime);
}

final class ToDateIssuesEvent extends IssuesManagementEvent {
  final DateTime dateTime;
  ToDateIssuesEvent(this.dateTime);
}

final class SubmitTicketEvent extends IssuesManagementEvent {}

final class SearchEvent extends IssuesManagementEvent {
  final String value;
  SearchEvent(this.value);
}

final class AcceptIssueEvent extends IssuesManagementEvent {}

class GetFilterIssuesEvent extends IssuesManagementEvent {
  final Map<String, String> param;
  GetFilterIssuesEvent(this.param);
}

class GetNextFilterIssuesEvent extends IssuesManagementEvent {
  final int offset;
  GetNextFilterIssuesEvent(this.offset);
}
