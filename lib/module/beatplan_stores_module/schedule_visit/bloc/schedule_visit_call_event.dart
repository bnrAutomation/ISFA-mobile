part of 'schedule_visit_call_bloc.dart';

enum SchuduleType { visit, call }

@immutable
abstract class ScheduleVisitCallEvent {}

class ScheduleTypeChangeEvent extends ScheduleVisitCallEvent {
  final SchuduleType to;

  ScheduleTypeChangeEvent(this.to);
}

class ScheduleVisitChangeStore extends ScheduleVisitCallEvent {
  final String storeName;

  ScheduleVisitChangeStore(this.storeName);
}

class ScheduleVisitChangeDateEvent extends ScheduleVisitCallEvent {
  final DateTime newDate;

  ScheduleVisitChangeDateEvent(this.newDate);
}

class ScheduleVisitChangeRemarkEvent extends ScheduleVisitCallEvent {
  final String remark;

  ScheduleVisitChangeRemarkEvent(this.remark);
}

class ScheduleVisitSaveEvent extends ScheduleVisitCallEvent {}
