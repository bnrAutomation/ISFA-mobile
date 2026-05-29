part of 'leave_bloc.dart';

@immutable
abstract class LeaveEvent {}

class GetLeaveDetailsEvent extends LeaveEvent {}

class GetLeaveBalanceEvent extends LeaveEvent {}

class ChangeLeaveTypeEvent extends LeaveEvent {
  final String leaveType;
  ChangeLeaveTypeEvent(this.leaveType);
}

class FromDateLeaveTypeEvent extends LeaveEvent {
  final DateTime dateTime;
  FromDateLeaveTypeEvent(this.dateTime);
}

class MeternatiyLeaveTypeEvent extends LeaveEvent {
  final DateTime dateTime;
  MeternatiyLeaveTypeEvent(this.dateTime);
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

class GetOptionalLeave extends LeaveEvent {}

class GetWeekOffLeave extends LeaveEvent {}

class GetUpcommingLeave extends LeaveEvent {}

class ApplyOptionalLeave extends LeaveEvent {}

class ChangeOptionalLeaveStatus extends LeaveEvent {
  final int index;
  final bool isActive;
  ChangeOptionalLeaveStatus(this.index, this.isActive);
}
class GetLeaveList extends LeaveEvent {}