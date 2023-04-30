import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/leaves_module/leave_repository.dart';
import 'package:i_densfa/module/leaves_module/model/leave_enums.dart';
import 'package:i_densfa/module/leaves_module/model/leave_type_model.dart';
import 'package:i_densfa/utility/extensions.dart';

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
  double get incompleteLeavePercent {
    if ((details?.totalLeave ?? 0) == 0) return 0;
    return (details?.leaveBalance ?? 1) / (details?.totalLeave ?? 1);
  }

  double get completeLeavePercent {
    final total = details?.totalLeave ?? 1;
    final used = details?.usedLeave ?? 1;
    if (total == 0) return 100;
    var calculated = (used / total) * 100;
    calculated = min(calculated, 100);
    return max(0, calculated);
  }

  double get fadeRotatedAngle {
    if (details?.totalLeave == 0) return 0;
    return details!.usedLeave / details!.totalLeave;
  }

  List<String> get tabbarTitles {
    final empLeaves = details?.empAppliedLeave ?? [];
    final reporteeLeaves = details?.reporteeRequestedLeave ?? [];
    List<String> titles = [];
    if (reporteeLeaves.isNotEmpty) titles.add('Requested Leaves');
    if (empLeaves.isNotEmpty) titles.add('Applied Leaves');
    return titles;
  }

  List<List<AppliedLeaveModel>> get tabbarLeavesList {
    final empLeaves = details?.empAppliedLeave ?? [];
    final reporteeLeaves = details?.reporteeRequestedLeave ?? [];
    List<List<AppliedLeaveModel>> lists = [];
    if (reporteeLeaves.isNotEmpty) lists.add(reporteeLeaves);
    if (empLeaves.isNotEmpty) lists.add(empLeaves);
    return lists;
  }

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
      if (toDate?.isBefore(event.dateTime) ?? false) {
        toDate = event.dateTime;
      }
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

    on((GetLeaveTypes event, emit) async => await _getLeaveOptions(emit));
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
  }

  Future<void> _applyLeave(Emitter<LeaveState> emit) async {
    if (selectLeaveType == null) {
      emit(LeaveViewShowSnack('Please select leave type'));
      return;
    }
    if (fromDate == null) {
      emit(LeaveViewShowSnack('Please select start date'));
      return;
    }
    if (selectedLeaveDayPart == LeaveDayPart.full && toDate == null) {
      emit(LeaveViewShowSnack('Please select end date'));
      return;
    }

    final DateTime endDate = toDate ?? fromDate!;

    if (fromDate!.weekday == DateTime.sunday) {
      emit(LeaveViewShowSnack(
          'Please select other weekday\nLeave ${fromDate!.isSameDate(endDate) ? "on" : "from"} sunday is not allowed'));
      return;
    }

    if (reason.isEmpty) {
      emit(LeaveViewShowSnack('Please enter reason'));
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
            toDate: endDate,
            reason: reason)
        .catchError((e) {
      emit(LeaveViewShowSnack(e.toString()));
      return false;
    });
    if (response) {
      if (tabbarTitles.length > 1) {
        bottomTabSelectedIndex = 1;
      }
      emit(LeaveAppliedSuccess());
      emit(LeaveViewShowSnack('Your leave is pending for approval.'));
      add(GetLeaveDetailsEvent());
    }
  }

  Future<void> _getLeaveOptions(Emitter<LeaveState> emit) async {
    emit(LeaveApplyLoadingState());
    var list = await repo.getLeaveTypes().catchError((error) {
      emit(LeaveViewWithData());
      emit(LeaveViewShowSnack(error.toString()));
      return <LeaveTypeModel>[];
    });
    list = list.where((element) => element.active).toList();
    list = list.where((element) {
      return (details?.leaveTypeBalance
              .map((e) => e.leaveTypeName)
              .contains(element.leaveType)) ??
          false;
    }).toList();
    Map<String, int> uniques = {};
    for (var item in list) {
      uniques[item.leaveType] = item.leaveId;
    }
    List<LeaveTypeModel> newList = [];
    for (var val in uniques.values) {
      final i = list.firstWhere((element) => element.leaveId == val);
      newList.add(i);
    }
    leaveOptions = newList;
    emit(LeaveViewWithData());
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
      add(GetLeaveDetailsEvent());
      if (approve) {
        emit(LeaveViewShowSnack('Leave is approved'));
      } else {
        emit(LeaveViewShowSnack('Leave is rejected'));
      }
    }
    return resp;
  }
}
