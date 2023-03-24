import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/leaves_module/model/leave_model.dart';

part 'leave_event.dart';
part 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectLeaveType;

  String selectedLeaveDayPart = 'Full';
  List<String> leaveDayParts = ['Full', 'First half', 'Second half'];

  LeaveBloc() : super(LeaveInitial()) {
    on<LeaveEvent>((event, emit) {
      if (event is ChangeLeaveTypeEvent) {
        selectLeaveType = event.leaveType;
        emit(ChangeLeaveTypeState());
      } else if (event is FromDateLeaveTypeEvent) {
        fromDate = event.dateTime ?? DateTime.now();
        emit(DateChangeLeaveState());
      } else if (event is ToDateLeaveTypeEvent) {
        toDate = event.dateTime ?? DateTime.now();
        emit(DateChangeLeaveState());
      }
    });
    on((ChangeLeaveDayPartEvent event, emit) {
      selectedLeaveDayPart = event.part;
      emit(ChangeLeaveTypeState());
    });
  }

  final List<LeavesData> leaveList = [
    LeavesData(
      LeaveType.casual,
      "28 Jan 2023",
      "30 Jan 2023",
      LeaveStatus.request,
    ), //requested
    LeavesData(
      LeaveType.sick,
      "28 Jan 2023",
      "30 Jan 2023",
      LeaveStatus.approve,
    ), //approved
    LeavesData(
      LeaveType.weekOff,
      "28 Jan 2023",
      "30 Jan 2023",
      LeaveStatus.reject,
    ), //rejected
    LeavesData(
      LeaveType.other,
      "28 Jan 2023",
      "30 Jan 2023",
      LeaveStatus.reject,
    ), //rejected
  ];
}
