part of 'issue_management_detail_bloc.dart';

@immutable
sealed class IssueManagementDetailState {}

final class IssueManagementDetailInitial extends IssueManagementDetailState {}

final class IssueManagementDetailLoading extends IssueManagementDetailState {}

final class SuccessfulIssueManagementDetailLoadState
    extends IssueManagementDetailState {}

final class IssueManagementDetailErroState extends IssueManagementDetailState {
  final String message;
  IssueManagementDetailErroState(this.message);
}

final class DataChangeState extends IssueManagementDetailState {}

final class SubmitStatusLoading extends IssueManagementDetailState {}

final class SubmitStatusSuccessfully extends IssueManagementDetailState {}

final class AcceptIssueLoading extends IssueManagementDetailState {}

final class AcceptIssueSuccess extends IssueManagementDetailState {}
