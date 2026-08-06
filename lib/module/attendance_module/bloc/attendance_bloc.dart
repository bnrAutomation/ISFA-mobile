// ignore_for_file: invalid_return_type_for_catch_error, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/attendance_module/attendance_repository.dart';
import 'package:i_densfa/module/attendance_module/model/attendance_model.dart';
import 'package:i_densfa/module/attendance_module/model/attendance_request_model.dart';
import 'package:i_densfa/utility/extensions.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  DateTime selectedOne = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime selectedSecond = DateTime.now();
  DateTime requestSelected = DateTime.now();
  DateTime? fromDate;
  DateTime? toDate;
  final AttendanceRepository repo;
  List<AttandanceDataNew> attandenceData = [];
  List<DateTime> leavesDate = [];
  String reason = "";
  String? selectedAttendanceType;
  static const List<String> attendanceTypeOptions = [
   // "Work From Home",
    "Out of Station",
  ];
  List<AttendanceRequestData> attendanceRequest = [];
  TimeOfDay selectedStartTime = const TimeOfDay(hour: 8, minute: 00);
  TimeOfDay selectedEndTime = const TimeOfDay(hour: 17, minute: 30);

  bool isallCheck = false;

  bool islongPress=false;
  

  late ScrollController scrollController =  ScrollController();
  double savedPosition = 0.0;


  AttendanceBloc(this.repo) : super(MyActivityInitial()) {
    scrollController.addListener(() {
      savedPosition = scrollController.offset;
    });
  
    on<GetAttendanceEvent>((event, emit) async =>
        await _getAttendance(emit, selectedOne, selectedSecond));

    on<GetLeaveList>((event, emit) async => await _getLeaveDates(emit));

    on<AllCheckRequest>((event, emit) {
      for (var item in attendanceRequest) {
        if (item.healthStatus == null) {
          item.isSeleted = event.ischeck;
        }
      }
      isallCheck=event.ischeck;
    scrollController = ScrollController(
       initialScrollOffset: savedPosition,
    );
      add(DateChangedEvent());
    });

    on<MyActivityChangeMonth>((event, emit) {
      selectedOne = event.fromTime;
      selectedSecond = event.toTime;
      if (selectedSecond.isBefore(event.fromTime)) {
        selectedSecond = event.fromTime;
      }
      emit(MyAcivityMonthChangeState());
      add(GetAttendanceEvent());
    });
    on<ToDateAttendanceEvent>((event, emit) {
      toDate = event.toDate;
      emit(AttendanceDateChangeState());
    });
    on<FromDateAttendanceEvent>((event, emit) {
      fromDate = event.fromDate;
      if (toDate?.isBefore(event.fromDate) ?? false) {
        toDate = event.fromDate;
      }
      emit(AttendanceDateChangeState());
    });
    on<ApplyNewAttendance>((event, emit) async => await _applyAttendance(emit));
    on<GetAllRequestEvent>(
        (event, emit) async => await _getRequest(emit, requestSelected));
    on<RequestResonseEvent>(
        (event, emit) async => await _setRequestRespnse(event, emit));
    
    on<SingleRequestResonseEvent>(
        (event, emit) async => await _setSingleRequestRespnse(event, emit));
    

    on<DateChangedEvent>((event, emit) {
       scrollController = ScrollController(
       initialScrollOffset: savedPosition,
    );
      emit(AttendanceDateChangeState());
    });

    on<RequestChangeMonth>((event, emit) {
      requestSelected = event.dateTime;
      emit(MyAcivityMonthChangeState());
      add(GetAllRequestEvent());
    });
  }

  Future<TimeOfDay?> selectTime(
      BuildContext context, TimeOfDay? initialTime) async {
    return await showTimePicker(
        context: context, initialTime: initialTime ?? TimeOfDay.now());
  }

  Future<void> _getAttendance(
      Emitter<AttendanceState> emit, DateTime fromTime, DateTime toTime) async {
    emit(AttendanceLoadingState());
    attandenceData = await repo
        .getUserAttendance(fromDate: fromTime, toDate: toTime)
        .catchError((error) {
      emit(MyActivityWithData());
      emit(AttendanceShowSnack(error.toString()));
      return <AttendanceData>[];
    });
    attandenceData.sort((a, b) => a.date.compareTo(b.date));
    emit(MyActivityWithData());
  }

  Future<void> _getLeaveDates(Emitter<AttendanceState> emit) async {
    try {
      emit(AttendanceLoadingState());
      leavesDate = await repo.getLeaveDates();
      emit(MyActivityWithData());
    } catch (e) {
      emit(AttendanceShowSnack(e.toString()));
    }
  }

  Future<void> _applyAttendance(Emitter<AttendanceState> emit) async {
    if (fromDate == null) {
      emit(AttendanceShowSnack('Please select start date'));
      return;
    }
    if (toDate == null) {
      emit(AttendanceShowSnack('Please select to date'));
      return;
    }
    // final DateTime endDate = toDate ?? fromDate!;
    if (fromDate!.weekday == DateTime.sunday) {
      emit(AttendanceShowSnack(
          'Please select other weekday\nAttendance ${fromDate!.isSameDate(toDate!) ? "on" : "from"} sunday is not allowed'));
      return;
    }
    if ((selectedStartTime.toDouble() > selectedEndTime.toDouble())
    // || ((selectedEndTime.toDouble() - selectedStartTime.toDouble())<9)
     
     ) {
      emit(AttendanceShowSnack('Please enter valid attendance time'));
      return;
    }
    // final isBrother = (AppStorage().userDetail?.companyName ?? '').toLowerCase().trim() == 'brotherinternational';
    // if (isBrother && (selectedAttendanceType == null || selectedAttendanceType!.isEmpty)) {
    //   emit(AttendanceShowSnack('Please select attendance type'));
    //   return;
    // }
    if (reason.isEmpty) {
      emit(AttendanceShowSnack('Please enter reason'));
      return;
    }
    emit(LoadingState());
    final response = await repo
        .applyAttendance(
            fromDate: fromDate!,
            toDate: toDate!,
            reason: reason,
            attendanceType: selectedAttendanceType,
            fromTime: selectedStartTime,
            toTime: selectedEndTime)
        .catchError((e) {
      emit(AttendanceShowSnack(e.toString()));
      return false;
    });

    if (response) {
      selectedAttendanceType = null;
      reason = "";
      emit(AttendanceAppliedSuccess());
      emit(AttendanceShowSnack('Your request is pending for approval.'));
      add(GetAttendanceEvent());
    }
  }

  Future<void> _getRequest(
      Emitter<AttendanceState> emit, DateTime selected) async {
    emit(AttendanceLoadingState());
    attendanceRequest =
        await repo.getAttendanceRequest(dateTime: selected).catchError((error) {
      emit(MyActivityWithData());
      emit(AttendanceShowSnack(error.toString()));
      return <AttendanceData>[];
    });

    emit(MyActivityWithData());
  }

   Future<void> _setSingleRequestRespnse(
      SingleRequestResonseEvent event, Emitter<AttendanceState> emit) async {
    List<int> selectedIds = [event.attandanceId];
    
    if(selectedIds.isEmpty){
       emit(AttendanceShowSnack('Mandatory to choose at least one request for any action.'));
       return ;
    }
    emit(AcceptLoadingState());
    final resp = await repo
        .attendanceAction(event.isAccepted, selectedIds)
        .catchError((e) {
      emit(MyActivityWithData());
      emit(AttendanceShowSnack(e.toString()));
      return false;
    });
    if (resp) {
         isallCheck = false;
         islongPress=false;
     for(int id in selectedIds){    
      attendanceRequest
          .singleWhere((element) => element.attendanceId == id).healthStatus = event.isAccepted;
     }
      
    //  add(GetAllRequestEvent());
      if (event.isAccepted) {
        emit(AttendanceShowSnack('Request is approved'));
      } else {
        emit(AttendanceShowSnack('Request is rejected'));
      }
    }
  }

  Future<void> _setRequestRespnse(
      RequestResonseEvent event, Emitter<AttendanceState> emit) async {
    List<int> selectedIds = attendanceRequest
        .where((item) => item.isSeleted)
        .map((item) => item.attendanceId)
        .toList();

    if(selectedIds.isEmpty){
       emit(AttendanceShowSnack('Mandatory to choose at least one request for any action.'));
       return ;
    }
    emit(AcceptLoadingState());
    final resp = await repo
        .attendanceAction(event.isAccepted, selectedIds)
        .catchError((e) {
      emit(MyActivityWithData());
      emit(AttendanceShowSnack(e.toString()));
      return false;
    });
    if (resp) {
         isallCheck = false;
         islongPress=false;
     for(int id in selectedIds){    
      attendanceRequest
          .singleWhere((element) => element.attendanceId == id).healthStatus = event.isAccepted;
     }
      
    //  add(GetAllRequestEvent());
      if (event.isAccepted) {
        emit(AttendanceShowSnack('Request is approved'));
      } else {
        emit(AttendanceShowSnack('Request is rejected'));
      }
    }
  }
}
