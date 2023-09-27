import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

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
  DateTime? selectedDate;
  String remark = '';
  void handleEvents() {
    on<ScheduleVisitCallEvent>((event, emit) {
      if (event is ScheduleTypeChangeEvent) {
        schedulingFor = event.to;
        emit(ScheduleVisitCallTypeChangeSate());
      }
    });

    on((ScheduleVisitChangeStore event, emit) {
      selectedStore = beatPlans
          .firstWhere((element) => element.storeName == event.storeName);
      emit(ScheduleVisitCallStoreChangeSate());
    });

    on((ScheduleVisitChangeDateEvent event, emit) {
      selectedDate = event.newDate;
      emit(ScheduleVisitCallDateChangeSate());
    });

    on((ScheduleVisitChangeRemarkEvent event, emit) => remark = event.remark);

    on((ScheduleVisitSaveEvent event, emit) async {
      if (remark.isEmpty) {
        emit(ScheduleVisitCallSnackBar('Please enter agenda'));
        return;
      }
      if (selectedDate == null) {
        emit(ScheduleVisitCallSnackBar('Please select date'));
        return;
      }
      final userId = AppStorage().userDetail!.id;
      final companyId = AppStorage().homeInfo!.userInfo.companyId;
      emit(ScheduleVisitCallLoadingState());
      final response = await CustomHttpBaseClient().post(
        Uri.parse(URLConstants.sheduleVisit),
        body: jsonEncode({
          "companyId": companyId,
          "pjpDate": selectedDate!.toStringFormat("yyyy-MM-dd"),
          "remarks": remark,
          "storeId": selectedStore.storeId,
          "userId": userId
        }),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${AppStorage().authToken}",
        },
      );

      if (response.statusCode == 200) {
        emit(ScheduleVisitCallSnackBar('Schedule added successfully'));
        emit(ScheduleVisitCallSuccessState());
      } else {
        final mess = getErrorMessage(response.body);
        emit(ScheduleVisitCallSnackBar(mess));
      }
    });
  }
}
