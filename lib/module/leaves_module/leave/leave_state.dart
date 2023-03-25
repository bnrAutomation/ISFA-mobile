part of 'leave_bloc.dart';

@immutable
abstract class LeaveState {}

class LeaveInitial extends LeaveState {}

class LeaveViewLoading extends LeaveState {}

class LeaveViewWithData extends LeaveState {}
