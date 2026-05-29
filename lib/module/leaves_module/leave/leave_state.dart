part of 'leave_bloc.dart';

@immutable
abstract class LeaveState {}

class LeaveInitial extends LeaveState {}

class LeaveViewLoading extends LeaveState {}

class LeaveViewWithData extends LeaveState {}

class LeaveViewShowSnack extends LeaveState {
  final String message;

  LeaveViewShowSnack(this.message);
}

class LeaveAppliedSuccess extends LeaveState {
   final String message;

  LeaveAppliedSuccess(this.message);
}

class LoadingState extends LeaveState {}

class LeaveApplyLoadingState extends LeaveState {}

class OptionalLeaveStateChange extends LeaveState {}
