import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'package:i_densfa/module/assessment_module/assessment_repository.dart';
part 'assessment_event.dart';
part 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final AssessmentRepository repo;
  List<AssessmentDetailModel> userAssessments = [];
  AssessmentDetailModel? selectedAssessment;
  List<AssessQuestionModel> selectedAssessQuestions = [];
  var selectedPieChartPortionId = -1;

  var pieChartReportData = [60, 25, 15];

  AssessmentBloc(this.repo) : super(AssessmentInitial()) {
    on<AssessmentEvent>((event, emit) {
      if (event is AssessmentTouchChanged) {
        selectedPieChartPortionId = event.index;
        emit(AssessmentInitial());
      }
    });
    on((GetUserAssessmentsEvent event, emit) async {
      emit(AssessmentListLoadingState());
      userAssessments = await repo.getAssessmentForUser();
      emit(AssessmentListLoadedState());
    });

    on((GetQuestionsForAssessment event, emit) async {
      selectedAssessment = userAssessments
          .firstWhere((element) => element.assessmentId == event.id);
      selectedAssessQuestions = await repo.getQuestions(event.id);
    });
  }
}
