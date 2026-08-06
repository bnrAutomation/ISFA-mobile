part of 'attendance_bloc.dart';

@immutable
abstract class AttendanceState {}

class MyActivityInitial extends AttendanceState {}

class MyAcivityMonthChangeState extends AttendanceState {}

class AttendanceLoadingState extends AttendanceState {}

class MyActivityWithData extends AttendanceState {}

class AttendanceShowSnack extends AttendanceState {
  final String message;
  AttendanceShowSnack(this.message);
}

class AttendanceDateChangeState extends AttendanceState {}

class LoadingState extends AttendanceState {}
class AcceptLoadingState extends AttendanceState {}

class AttendanceAppliedSuccess extends AttendanceState {}
