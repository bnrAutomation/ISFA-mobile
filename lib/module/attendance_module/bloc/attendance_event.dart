part of 'attendance_bloc.dart';

@immutable
abstract class MyActivityEvent {}

class GetAttendanceEvent extends MyActivityEvent {}

class MyActivityChangeMonth extends MyActivityEvent {
  final DateTime dateTime;
  MyActivityChangeMonth(this.dateTime);
}
