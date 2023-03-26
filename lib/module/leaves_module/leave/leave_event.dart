part of 'leave_bloc.dart';

@immutable
abstract class LeaveEvent {}

class GetLeaveDetailsEvent extends LeaveEvent {}

class ChangeLeaveTypeEvent extends LeaveEvent {
  final String leaveType;
  ChangeLeaveTypeEvent(this.leaveType);
}

class FromDateLeaveTypeEvent extends LeaveEvent {
  final DateTime dateTime;
  FromDateLeaveTypeEvent(this.dateTime);
}

class ToDateLeaveTypeEvent extends LeaveEvent {
  final DateTime dateTime;
  ToDateLeaveTypeEvent(this.dateTime);
}

class ChangeLeaveDayPartEvent extends LeaveEvent {
  final LeaveDayPart part;
  ChangeLeaveDayPartEvent(this.part);
}

class ApplyNewLeave extends LeaveEvent {}

class RespondToLeaveEvent extends LeaveEvent {
  final bool approved;
  final int id;

  RespondToLeaveEvent(this.approved, this.id);
}

class GetLeaveTypes extends LeaveEvent {}
