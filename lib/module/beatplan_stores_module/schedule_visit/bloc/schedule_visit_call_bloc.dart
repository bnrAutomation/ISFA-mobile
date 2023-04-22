import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/beatplan_stores_module/beat_plan_model.dart';

part 'schedule_visit_call_event.dart';
part 'schedule_visit_call_state.dart';

class ScheduleVisitCallBloc
    extends Bloc<ScheduleVisitCallEvent, ScheduleVisitCallState> {
  List<BeatPlanModel> beatPlans;
  ScheduleVisitCallBloc(this.beatPlans) : super(ScheduleVisitCallInitial()) {
    handleEvents();
  }

  SchuduleType schedulingFor = SchuduleType.visit;
  late BeatPlanModel selectedStore = beatPlans.first;

  void handleEvents() {
    on<ScheduleVisitCallEvent>((event, emit) {
      if (event is ScheduleTypeChangeEvent) {
        schedulingFor = event.to;
        emit(ScheduleVisitCallTypeChangeSate());
      }
    });
  }
}
