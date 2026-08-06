part of 'issue_management_detail_bloc.dart';

@immutable
sealed class IssueManagementDetailEvent {}

final class GetTicketDetailEvent extends IssueManagementDetailEvent {}

final class DataChangeEvent extends IssueManagementDetailEvent {}

final class SubmitTicketEvent extends IssueManagementDetailEvent {}

final class AcceptIssueEvent extends IssueManagementDetailEvent {}
