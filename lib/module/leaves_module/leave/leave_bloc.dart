import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/leaves_module/leave_repository.dart';
import 'package:i_densfa/module/leaves_module/model/leave_enums.dart';
import 'package:i_densfa/module/leaves_module/model/leave_type_model.dart';

import '../../../utility/app_constants.dart';
import '../model/leave_model.dart';

part 'leave_event.dart';
part 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository repo;
  DateTime? fromDate;
  DateTime? toDate;
  String? selectLeaveType;
  String reason = '';
  int bottomTabSelectedIndex = 0;

  LeaveDayPart selectedLeaveDayPart = LeaveDayPart.full;

  EmpLeaveDetailsModel? details;
  List<LeaveTypeModel> leaveOptions = [];

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

  Color getColorFromLeaveType(String type) {
    switch (type) {
      case 'Sick Leave':
        return Colors.red;

      default:
        return Colors.black;
    }
  }

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
    on((GetLeaveDetailsEvent event, emit) async => await _getEmpDetails(emit));
    on((ApplyNewLeave event, emit) async => await _applyLeave(emit));
    on((RespondToLeaveEvent event, emit) async =>
        await _respondToLeave(event.approved, event.id, emit));
  }

  Future<void> _getEmpDetails(Emitter<LeaveState> emit) async {
    emit(LeaveViewLoading());
    await repo.getDetails().then((value) {
      details = value;
      emit(LeaveViewWithData());
    }).catchError((error) {
      details = null;
      emit(LeaveViewWithData());
      emit(LeaveViewShowSnack(error.toString()));
    });
    _getLeaveOptions();
  }

  Future<void> _applyLeave(Emitter<LeaveState> emit) async {
    if (fromDate == null) {
      emit(LeaveViewShowSnack('Please select start date'));
      return;
    }
    if (toDate == null) {
      emit(LeaveViewShowSnack('Please select end date'));
      return;
    }
    if (selectLeaveType == null) {
      emit(LeaveViewShowSnack('Please select leave type'));
      return;
    }
    final leaveTypeId = leaveOptions
        .firstWhere((element) => element.leaveType == selectLeaveType)
        .leaveId;
    final response = await repo
        .applyLeave(
            leaveTypeId: leaveTypeId,
            dayId: selectedLeaveDayPart.getId,
            fromDate: fromDate!,
            toDate: toDate!,
            reason: reason)
        .catchError((e) {
      emit(LeaveViewShowSnack(e.toString()));
      return false;
    });
    if (response) {
      emit(LeaveAppliedSuccess());
      await _getEmpDetails(emit);
      fromDate = null;
      toDate = null;
      selectLeaveType = null;
      selectedLeaveDayPart = LeaveDayPart.full;
    }
  }

  Future<void> _getLeaveOptions() async {
    leaveOptions = await repo.getLeaveTypes();
  }

  Future<bool> _respondToLeave(
      bool approve, int id, Emitter<LeaveState> emit) async {
    emit(LeaveViewLoading());
    final resp = await repo.leaveAction(approve, id).catchError((e) {
      emit(LeaveViewWithData());
      emit(LeaveViewShowSnack(e.toString()));
      return false;
    });
    if (resp) {
      await _getEmpDetails(emit);
    }
    return resp;
  }
}
