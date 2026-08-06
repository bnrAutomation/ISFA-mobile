part of 'issues_management_bloc.dart';

@immutable
sealed class IssuesManagementState {}

final class IssuesManagementInitial extends IssuesManagementState {}

final class IssuesManagementLoading extends IssuesManagementState {}

final class SuccessfullyIssuesManagementState extends IssuesManagementState {}

final class IssuesManagementShowError extends IssuesManagementState {
  final String message;
  IssuesManagementShowError(this.message);
}

final class DataChangeState extends IssuesManagementState {}

final class SubmitStatusSuccessfully extends IssuesManagementState {}

final class SubmitStatusLoading extends IssuesManagementState {}

final class AcceptIssueLoading extends IssuesManagementState {}

final class AcceptIssueSuccess extends IssuesManagementState {}
