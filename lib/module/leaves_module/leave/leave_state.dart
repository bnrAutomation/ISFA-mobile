part of 'leave_bloc.dart';

@immutable
abstract class LeaveState {}

class LeaveInitial extends LeaveState {}

class ChangeLeaveTypeState extends LeaveState {}

class DateChangeLeaveState extends LeaveState {}
