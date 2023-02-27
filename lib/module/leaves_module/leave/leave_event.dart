part of 'leave_bloc.dart';

@immutable
abstract class LeaveEvent {}

class ChangeLeaveTypeEvent extends LeaveEvent {
  final String leaveType;
  ChangeLeaveTypeEvent(this.leaveType);
}

class FromDateLeaveTypeEvent extends LeaveEvent {
  final DateTime? dateTime;
  FromDateLeaveTypeEvent(this.dateTime);
}

class ToDateLeaveTypeEvent extends LeaveEvent {
  final DateTime? dateTime;
  ToDateLeaveTypeEvent(this.dateTime);
}
