import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'myactivity_event.dart';
part 'myactivity_state.dart';

class MyActivityBloc extends Bloc<MyActivityEvent, MyActivityState> {
  DateTime? selected = DateTime.now();
  MyActivityBloc() : super(MyActivityInitial()) {
    on<MyActivityEvent>((event, emit) {
      if (event is MyActivityChangeMonth) {
        selected = event.dateTime;
        emit(MyAcivityMonthChangeState());
      }
    });
  }
}
