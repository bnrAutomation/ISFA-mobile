import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/leaves_module/leave_repository.dart';
import 'package:i_densfa/module/leaves_module/model/leave_enums.dart';
import 'package:i_densfa/module/leaves_module/model/leave_type_model.dart';
import 'package:i_densfa/module/leaves_module/model/upcomingmodel.dart';
import 'package:i_densfa/module/leaves_module/model/upcomming_leave_model.dart';
import 'package:i_densfa/utility/app_storage.dart';

import '../../../utility/app_constants.dart';
import '../model/leave_model.dart';

part 'leave_event.dart';
part 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository repo;
  DateTime? fromDate;
  DateTime? toDate;
  DateTime? maternityDate;
  String? selectLeaveType;
  String reason = '';
  int bottomTabSelectedIndex = 0;
  LeaveDayPart selectedLeaveDayPart = LeaveDayPart.full;
  List<LeaveBalanceModel> leaveTypeBalance = [];
  List<DateTime> leavesDate = [];

  EmpLeaveDetailsModel? details;
  List<LeaveTypeModel> leaveOptions = [];
  List<UpcomingModel> upcommingLeave = [];
  List<LeaveDays> optionalLeave = [];
  List<DateTime> weekoff = [];
  int availabeOptionLeave = 0;
  bool canSubit = true;

  final double circleRadius = 60;

  String leaveDescreption = "";
  double get fadeCirlceDiameter => circleRadius * 2 + 19;

  bool isLoading = false;

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
    return (details?.usedLeave ?? 0.0) / (details?.totalLeave ?? 0.0);
  }

  List<String> get tabbarTitles {
    final empLeaves = details?.empAppliedLeave ?? [];
    final reporteeLeaves = details?.reporteeRequestedLeave ?? [];
    List<String> titles = [];
    if (reporteeLeaves.isNotEmpty) titles.add('Requested Leaves');
    if (empLeaves.isNotEmpty &&
        (AppStorage()
                .userDetail
                ?.userConfiguration
                .requiredAppliedLeaveRequest ??
            true)) {
      titles.add('Applied Leaves');
    }
    return titles;
  }

  List<List<AppliedLeaveModel>> get tabbarLeavesList {
    final empLeaves = details?.empAppliedLeave ?? [];
    final reporteeLeaves = details?.reporteeRequestedLeave ?? [];
    List<List<AppliedLeaveModel>> lists = [];
    if (reporteeLeaves.isNotEmpty) lists.add(reporteeLeaves);
    if (empLeaves.isNotEmpty &&
        (AppStorage()
                .userDetail
                ?.userConfiguration
                .requiredAppliedLeaveRequest ??
            true)) {
      lists.add(empLeaves);
    }
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

      String des = leaveOptions
          .singleWhere((element) => element.leaveType == event.leaveType)
          .leaveDesc;
      leaveDescreption =
          des.isEmpty || des == "Description" ? "" : "Note:\n$des";
      emit(LeaveViewWithData());
    });
    on<FromDateLeaveTypeEvent>((event, emit) {
      fromDate = event.dateTime;
      if (toDate?.isBefore(event.dateTime) ?? false) {
        toDate = event.dateTime;
      }
      emit(LeaveViewWithData());
    });
    on<MeternatiyLeaveTypeEvent>((event, emit) {
      maternityDate = event.dateTime;
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

    on<ChangeOptionalLeaveStatus>((event, emit) {
      optionalLeave[event.index].isActive = event.isActive;
      emit(OptionalLeaveStateChange());
    });
    on<ApplyOptionalLeave>(
        (event, emit) async => await _applyOptionalLeave(emit));

    on((GetLeaveBalanceEvent event, emit) async =>
        await _getLeaveBalance(emit));
    on((GetLeaveDetailsEvent event, emit) async => await _getEmpDetails(emit));

    on((ApplyNewLeave event, emit) async => await _applyLeave(emit));
    on((RespondToLeaveEvent event, emit) async =>
        await _respondToLeave(event.approved, event.id, emit));
    on<GetUpcommingLeave>(
        (event, emit) async => await _getUpcommingLeave(emit));
    on<GetOptionalLeave>((event, emit) async => await _getOptionalLeave(emit));
    on<GetWeekOffLeave>((event, emit) async => await _getWeekOffLeave(emit));
    on((GetLeaveTypes event, emit) async => await _getLeaveOptions(emit));
     on<GetLeaveList>((event, emit) async =>
        await _getLeaveDates(emit));


  }

    Future<void> _getLeaveDates(
      Emitter<LeaveState> emit) async {
        try{
     emit(LeaveViewLoading());
    leavesDate = await repo.getLeaveDates();
     emit(LeaveViewWithData());
     
    
    }catch(e){
          emit(LeaveViewShowSnack(e.toString()));
        }
  }
  List<DateTime> getDatesBetween(DateTime? from, DateTime? to) {
    if (from == null) return [];
    if (to == null) return [];

    List<DateTime> dates = [];
    for (int i = 0;
        from.add(Duration(days: i)).isBefore(to) ||
            from.add(Duration(days: i)).isAtSameMomentAs(to);
        i++) {
      dates.add(from.add(Duration(days: i)));
    }
    return dates;
  }

  Future<void> _getWeekOffLeave(Emitter<LeaveState> emit) async {
    try {
      // Load week-off dates without blocking the entire view
      List<WeekOffModel> weekoffList = await repo.getWeekOffLeave();
      weekoff = [];
      for (var element in weekoffList) {
        weekoff.addAll(getDatesBetween(element.dateFrom, element.dateTo));
      }
      emit(LeaveViewWithData());
    } catch (error) {
      details = null;
      emit(LeaveViewWithData());
      emit(LeaveViewShowSnack(error.toString()));
    }
  }

  Future<void> _getOptionalLeave(Emitter<LeaveState> emit) async {
    try {
      // Load optional leave data in the background
      DataList? value = await repo.getOptionalLeave();
      optionalLeave = value?.days ?? [];
      availabeOptionLeave = value?.availableLeave ?? 0;
      canSubit = canSubmit(optionalLeave, availabeOptionLeave);
      emit(LeaveViewWithData());
    } catch (error) {
      details = null;
      emit(LeaveViewWithData());
      emit(LeaveViewShowSnack(error.toString()));
    }
  }

  Future<void> _getUpcommingLeave(Emitter<LeaveState> emit) async {
    // Fetch upcoming leaves without showing a full-screen loader
    await repo.getUpcommingLeave().then((value) {
      upcommingLeave = value;
      //  emit(LeaveViewWithData());
    }).catchError((error) {
      details = null;
      emit(LeaveViewWithData());
      emit(LeaveViewShowSnack(error.toString()));
    });
  }

  Future<void> _getLeaveBalance(Emitter<LeaveState> emit) async {
    await repo.getLeaveBalance().then((value) {
     // value.leaveTypeBalance.removeWhere((element)=>element.leaveTypeName.toLowerCase().trim()== "weekly off".trim());
      leaveTypeBalance = value.leaveTypeBalance;
    //  leaveTypeBalance.removeWhere((element)=>element.leaveTypeName.toLowerCase().trim()== "weekly off".trim());
      emit(LeaveViewWithData());
    }).catchError((error) {
      emit(LeaveViewWithData());
      emit(LeaveViewShowSnack(error.toString()));
    });
  }

  Future<void> _getEmpDetails(Emitter<LeaveState> emit) async {
    isLoading = true;
    emit(LeaveViewLoading());
    await repo.getDetails().then((value) {
      details = value;
      isLoading = false;
      emit(LeaveViewWithData());
    }).catchError((error) {
      details = null;
      isLoading = false;
      emit(LeaveViewWithData());
      emit(LeaveViewShowSnack(error.toString()));
    });
  }

  Future<void> _applyOptionalLeave(Emitter<LeaveState> emit) async {
    emit(LoadingState());
    if (!isValidOptionalLeave(optionalLeave, availabeOptionLeave)) {
      emit(LeaveViewShowSnack(
          'You can apply maximum $availabeOptionLeave leave'));
      return;
    }

    List<LeaveDays> applyLeave =
        optionalLeave.where((element) => element.isActive == true).toList();
    final response =
        await repo.applyOptionalLeave({"days": applyLeave}).catchError((e) {
      emit(LeaveViewShowSnack(e.toString()));
      return LeaveApplyResposne(message: e.toString(),status: "301");
    });

    if (response.status=="200"||response.status=="201") {
      emit(LeaveAppliedSuccess(response.message));
     // emit(LeaveViewShowSnack('Leave Applied Sucessfully'));
      add(GetOptionalLeave());
    }
  }

  Future<void> _applyLeave(Emitter<LeaveState> emit) async {
    try{
    if (selectLeaveType == null) {
      emit(LeaveViewShowSnack('Please select leave type'));
      return;
    }
    if (fromDate == null) {
      emit(LeaveViewShowSnack('Please select start date'));
      return;
    }
    if (selectedLeaveDayPart == LeaveDayPart.full 
    &&  selectLeaveType?.trim().toLowerCase() !=
                                            "weekly off".trim() && toDate == null) {
      emit(LeaveViewShowSnack('Please select end date'));
      return;
    }

    final DateTime endDate = toDate ?? fromDate!;

    // if (AppStorage().userDetail?.companyName.toLowerCase() !=
    //     "Mobil".toLowerCase()|| AppStorage().userDetail?.companyName.toLowerCase()!="ExxonMobil Mobile Miles Plant".toLowerCase()) {
    //   if (fromDate!.weekday == DateTime.sunday) {
    //     emit(LeaveViewShowSnack(
    //         'Please select other weekday\nLeave ${fromDate!.isSameDate(endDate) ? "on" : "from"} sunday is not allowed'));
    //     return;
    //   }
    // }

    if (reason.isEmpty) {
      emit(LeaveViewShowSnack('Please enter reason'));
      return;
    }
    if (selectLeaveType?.toLowerCase().trim() == "maternity leave".trim() &&
        maternityDate == null) {
      emit(LeaveViewShowSnack('Please Choose delivery date'));
      return;
    }

    if (selectLeaveType?.toLowerCase().trim() == "sick leave".trim()) {
      if (calculateWeekdays(fromDate!, endDate) > 3) {
        emit(LeaveViewShowSnack(
            'You should submit the medical certificate or supporting documents.'));
      }
    }
    final leaveTypeId = leaveOptions
        .firstWhere((element) => element.leaveType == selectLeaveType)
        .leaveId;

    emit(LoadingState());
    final response = await repo
        .applyLeave(
            leaveTypeId: leaveTypeId,
            dayId: selectedLeaveDayPart.getId,
            fromDate: fromDate!,
            toDate: endDate,
            reason: reason,
            maternityDate: maternityDate)
        .catchError((e) {
      emit(LeaveViewShowSnack(e.toString()));
      return LeaveApplyResposne(status:"300",message: e.toString());
    });

    if (response.status=="200"||response.status=="201") {
      if (tabbarTitles.length > 1) {
        bottomTabSelectedIndex = 1;
      }
      emit(LeaveAppliedSuccess(response.message));
      add(GetLeaveDetailsEvent());
      add(GetLeaveBalanceEvent());
      add(GetLeaveList());
    }
    }catch( e){
      emit(LeaveViewShowSnack(e.toString()));
    }
  }

// Function to check if a given date is a weekend (Saturday or Sunday)
  bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

// Function to calculate number of days excluding weekends between two dates
  int calculateWeekdays(DateTime startDate, DateTime endDate) {
    int count = 0;
    DateTime currentDate = startDate;

    // Iterate through each day from startDate to endDate
    while (currentDate.isBefore(endDate) || currentDate == endDate) {
      if (!isWeekend(currentDate)) {
        count++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return count;
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
      return AppStorage().userDetail?.companyName == "BrotherInternational"
          ? (leaveTypeBalance
                  .map((e) => e.leaveTypeName)
                  .contains(element.leaveType) ||
              element.leaveType.trim().toLowerCase() ==
                  "Weekly off".trim().toLowerCase())
          : (leaveTypeBalance
              .map((e) => e.leaveTypeName)
              .contains(element.leaveType));
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

  bool canSubmit(List<LeaveDays> optionalLeave, int availabeOptionLeave) {
    int count = 0;
    for (var element in optionalLeave) {
      if (element.isActive == true) {
        count++;
      }
    }
    return count < availabeOptionLeave;
  }

  bool isValidOptionalLeave(
      List<LeaveDays> optionalLeave, int availabeOptionLeave) {
    int count = 0;
    for (var element in optionalLeave) {
      if (element.isActive == true) {
        count++;
      }
    }
    return count <= availabeOptionLeave;
  }
}
