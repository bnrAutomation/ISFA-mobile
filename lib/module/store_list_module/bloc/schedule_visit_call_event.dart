part of 'schedule_visit_call_bloc.dart';

enum SchuduleType { visit, call }

@immutable
abstract class ScheduleVisitCallEvent {}

class ScheduleTypeChangeEvent extends ScheduleVisitCallEvent {
  final SchuduleType to;

  ScheduleTypeChangeEvent(this.to);
}
