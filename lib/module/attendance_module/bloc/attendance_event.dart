part of 'attendance_bloc.dart';

@immutable
abstract class AttendanceEvent {}

class GetAttendanceEvent extends AttendanceEvent {}

class MyActivityChangeMonth extends AttendanceEvent {
  final DateTime fromTime;
  final DateTime toTime;
  MyActivityChangeMonth(this.fromTime, this.toTime);
}

class ToDateAttendanceEvent extends AttendanceEvent {
  final DateTime toDate;
  ToDateAttendanceEvent(this.toDate);
}

class FromDateAttendanceEvent extends AttendanceEvent {
  final DateTime fromDate;
  FromDateAttendanceEvent(this.fromDate);
}

class ApplyNewAttendance extends AttendanceEvent {}

class GetAllRequestEvent extends AttendanceEvent {}

class RequestResonseEvent extends AttendanceEvent {
   final bool isAccepted;
   RequestResonseEvent(this.isAccepted);
}

class SingleRequestResonseEvent extends AttendanceEvent {
  final int attandanceId;
   final bool isAccepted;
   SingleRequestResonseEvent(this.attandanceId,this.isAccepted);
}


class DateChangedEvent extends AttendanceEvent {}

class RequestChangeMonth extends AttendanceEvent {
  final DateTime dateTime;
  RequestChangeMonth(this.dateTime);
}
class GetLeaveList extends AttendanceEvent {}

class AllCheckRequest extends AttendanceEvent{
  final bool ischeck;
  AllCheckRequest(this.ischeck);
}
