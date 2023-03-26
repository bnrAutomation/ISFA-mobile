import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/leaves_module/leave_repository.dart';

import '../../../utility/app_constants.dart';
import '../model/leave_model.dart';

part 'leave_event.dart';
part 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository repo;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectLeaveType;

  String selectedLeaveDayPart = 'Full';
  List<String> leaveDayParts = ['Full', 'First half', 'Second half'];

  EmpLeaveDetailsModel? details;

  LeaveBloc(this.repo) : super(LeaveInitial()) {
    on<ChangeLeaveTypeEvent>((event, emit) {
      selectLeaveType = event.leaveType;
      emit(LeaveViewWithData());
    });
    on<FromDateLeaveTypeEvent>((event, emit) {
      fromDate = event.dateTime;
      emit(LeaveViewWithData());
    });
    on<ToDateLeaveTypeEvent>((event, emit) {
      toDate = event.dateTime;
      emit(LeaveViewWithData());
    });
    on((ChangeLeaveDayPartEvent event, emit) {
      selectedLeaveDayPart = event.part;
      emit(LeaveViewWithData());
    });
    on((GetLeaveDetailsEvent event, emit) => getEmpDetails(emit));
  }

  Future<void> getEmpDetails(Emitter<LeaveState> emit) async {
    emit(LeaveViewLoading());
    await repo.getDetails().then((value) {
      details = value;
      emit(LeaveViewWithData());
    }).onError((error, stackTrace) {
      details = null;
      emit(LeaveViewWithData());
    });
  }

  final double circleRadius = 60;
  double get fadeCirlceDiameter => circleRadius * 2 + 15;
  double get incompleteLeavePercent =>
      (details?.leaveBalance ?? 1) / (details?.totalLeave ?? 1);
  double get completeLeavePercent =>
      ((details?.usedLeave ?? 1) / (details?.totalLeave ?? 1)) * 100;

  String getLeaveTypeBalanceIcon(int index) {
    switch (index) {
      case 0:
        return ImageConstants.doorOut;
      case 1:
        return ImageConstants.sick;
      case 2:
        return ImageConstants.walkman;
      default:
        return ImageConstants.sunumbrella;
    }
  }
}
