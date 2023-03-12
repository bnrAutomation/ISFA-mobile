import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'assessment_event.dart';
part 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  var touchedIndex = -1;

  var tagetCompleted = [60, 25, 15];

  AssessmentBloc() : super(AssessmentInitial()) {
    on<AssessmentEvent>((event, emit) {
      if (event is AssessmentTouchChanged) {
        touchedIndex = event.index;
        emit(AssessmentInitial());
      }
    });
  }
}
