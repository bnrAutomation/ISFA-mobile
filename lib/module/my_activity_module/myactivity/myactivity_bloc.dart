// ignore_for_file: invalid_return_type_for_catch_error, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/my_activity_module/model/my_activity_model.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_repository.dart';

part 'myactivity_event.dart';
part 'myactivity_state.dart';

class MyActivityBloc extends Bloc<MyActivityEvent, MyActivityState> {
  DateTime? selected = DateTime.now();
  final MyActivityRepository repo;
  List<AttendanceData> attandenceData = [];
  MyActivityBloc(this.repo) : super(MyActivityInitial()) {
    on<GetActivityEvent>(
        (event, emit) async => await _getAttendance(emit, selected));
    on<MyActivityEvent>((event, emit) {
      if (event is MyActivityChangeMonth) {
        selected = event.dateTime;
        emit(MyAcivityMonthChangeState());
        add(GetActivityEvent());
      }
    });
  }

  Future<void> _getAttendance(
      Emitter<MyActivityState> emit, DateTime? dateTime) async {
    emit(MyAcivityLoadingState());
    var list =
        await repo.getMyActivity(dateTime: dateTime!).catchError((error) {
      emit(MyActivityWithData());
      emit(MyActivityShowSnack(error.toString()));
      return <AttendanceData>[];
    });

    attandenceData = list.where((element) => element.storeid != null).toList();
    emit(MyActivityWithData());
  }
}
