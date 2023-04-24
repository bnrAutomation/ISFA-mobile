import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/analytics_module/model/analytics_model.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  var selectedDate = DateTime.now();
  List<AnalyticsModel> analyticdata = [
    AnalyticsModel(name: "", target: "TARGET", actual: "ACTUAL"),
    AnalyticsModel(name: "Retailer Coverage", target: "5", actual: "3"),
    AnalyticsModel(name: "Mechanics Engaged", target: "10", actual: "8"),
    AnalyticsModel(name: "Trials Generated", target: "7", actual: "2"),
    AnalyticsModel(name: "Mechanics Leads", target: "5", actual: "3"),
    AnalyticsModel(name: "Number of oil changes", target: "10", actual: "4"),
    AnalyticsModel(
        name: "Number of consumers engaged", target: "10", actual: "4"),
  ];
  AnalyticsBloc() : super(AnalyticsInitial()) {
    on<AnalyticsEvent>((event, emit) {});
    on((AnalyticsDateChangeEvent event, emit) {
      selectedDate = event.date;
      emit(AnalyticsUpdateData());
    });
  }

  void onNextDateSelect() {
    final newDate = selectedDate.add(const Duration(days: 1));
    add(AnalyticsDateChangeEvent(newDate));
  }

  void onPreviousDateSelect() {
    final newDate = selectedDate.subtract(const Duration(days: 1));
    add(AnalyticsDateChangeEvent(newDate));
  }
}
