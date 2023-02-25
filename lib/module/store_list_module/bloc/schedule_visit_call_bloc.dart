import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'schedule_visit_call_event.dart';
part 'schedule_visit_call_state.dart';

class ScheduleVisitCallBloc
    extends Bloc<ScheduleVisitCallEvent, ScheduleVisitCallState> {
  ScheduleVisitCallBloc() : super(ScheduleVisitCallInitial()) {
    handleEvents();
  }

  SchuduleType schedulingFor = SchuduleType.visit;

  void handleEvents() {
    on<ScheduleVisitCallEvent>((event, emit) {
      if (event is ScheduleTypeChangeEvent) {
        schedulingFor = event.to;
        emit(ScheduleVisitCallTypeChangeSate());
      }
    });
  }
}
