import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/leaves_module/model/leave_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

part 'leave_event.dart';
part 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  DateTime? fromDate = DateTime.now();
  DateTime? toDate = DateTime.now();
  String selectLeaveType = "";

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
  }

  final List<LeavesData> leaveList = [
    LeavesData(
      statusConstants.casualTypeLeave,
      "28 Jan 2023",
      "30 Jan 2023",
      statusConstants.requestLeave,
    ), //requested
    LeavesData(
      statusConstants.sickTypeLeave,
      "28 Jan 2023",
      "30 Jan 2023",
      statusConstants.approveLeave,
    ), //approved
    LeavesData(
      statusConstants.weekOffTypeLeave,
      "28 Jan 2023",
      "30 Jan 2023",
      statusConstants.rejectLeave,
    ), //rejected
    LeavesData(
      statusConstants.otherTypeLeave,
      "28 Jan 2023",
      "30 Jan 2023",
      statusConstants.rejectLeave,
    ), //rejected
  ];
}
