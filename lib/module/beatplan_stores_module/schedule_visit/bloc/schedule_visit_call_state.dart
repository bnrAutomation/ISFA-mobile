part of 'schedule_visit_call_bloc.dart';

@immutable
abstract class ScheduleVisitCallState {}

class ScheduleVisitCallInitial extends ScheduleVisitCallState {}

class ScheduleVisitCallTypeChangeSate extends ScheduleVisitCallState {}

class ScheduleVisitCallStoreChangeSate extends ScheduleVisitCallState {}

class ScheduleVisitCallDateChangeSate extends ScheduleVisitCallState {}

class ScheduleVisitCallSnackBar extends ScheduleVisitCallState {
  final String message;

  ScheduleVisitCallSnackBar(this.message);
}

class ScheduleVisitCallLoadingState extends ScheduleVisitCallState {}

class ScheduleVisitCallSuccessState extends ScheduleVisitCallState {}
