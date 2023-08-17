import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/analytics_module/analytics_repository.dart';
import 'package:i_densfa/module/analytics_module/model/analytics_model.dart';
import 'package:i_densfa/utility/app_storage.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final userDetails = AppStorage().userDetail!;

  final AnalyticsRepository repo;
  int selectedDays = 30;

  List<int> daysFilterOptions = [45, 30, 15, 7];

  List<AnalyticsModel> analyticsList = [];
  AnalyticsBloc(this.repo) : super(AnalyticsInitial()) {
    on((AnalyticsDaysChangeEvent event, emit) {
      selectedDays = event.days;
      add(GetAnalyticsEvent());
    });

    on((GetAnalyticsEvent event, emit) async {
      try {
        final details = await repo.getDetails(days: selectedDays);
        analyticsList = details;
        emit(AnalyticsUpdateData());
      } catch (e) {
        emit(AnalyticsSnackBarMessage(e.toString()));
      }
    });
  }
}
