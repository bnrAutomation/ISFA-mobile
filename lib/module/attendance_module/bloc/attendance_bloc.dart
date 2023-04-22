// ignore_for_file: invalid_return_type_for_catch_error, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/attendance_module/attendance_repository.dart';
import 'package:i_densfa/module/attendance_module/model/attendance_model.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<MyActivityEvent, AttendanceState> {
  DateTime selected = DateTime.now();
  final AttendanceRepository repo;
  List<AttendanceData> attandenceData = [];
  AttendanceBloc(this.repo) : super(MyActivityInitial()) {
    on<GetAttendanceEvent>(
        (event, emit) async => await _getAttendance(emit, selected));
    on<MyActivityEvent>((event, emit) {
      if (event is MyActivityChangeMonth) {
        selected = event.dateTime;
        emit(MyAcivityMonthChangeState());
        add(GetAttendanceEvent());
      }
    });
  }

  Future<void> _getAttendance(
      Emitter<AttendanceState> emit, DateTime dateTime) async {
    emit(AttendanceLoadingState());
    attandenceData =
        await repo.getMyActivity(dateTime: dateTime).catchError((error) {
      emit(MyActivityWithData());
      emit(AttendanceShowSnack(error.toString()));
      return <AttendanceData>[];
    });

    emit(MyActivityWithData());
  }
}
