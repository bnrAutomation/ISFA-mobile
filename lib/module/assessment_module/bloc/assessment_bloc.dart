import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'package:i_densfa/module/assessment_module/assessment_repository.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';
part 'assessment_event.dart';
part 'assessment_state.dart';

class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final AssessmentRepository repo;
  List<AssessmentDetailModel> userAssessments = [];
  AssessmentDetailModel? selectedAssessment;
  List<AssessQuestionModel> selectedAssessQuestions = [];
  var selectedPieChartPortionId = -1;

  List<QuestionModel> questionAnswers = [];
  int _secondsTook = 0;
  Timer? _timer;

  String timeLeft() {
    final totalMin = selectedAssessment?.duration ?? 1;
    final totalSeconds = totalMin * 60;
    final time = totalSeconds - _secondsTook;
    int sec = time % 60;
    int min = (time / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

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
      questionAnswers =
          selectedAssessQuestions.map((e) => e.toViewQuestionModel()).toList();
      emit(AssessmentQuestionsLoadedState());
    });

    on((SaveAssessmentAnswersEvent event, emit) async {
      _timer?.cancel();
      final notAnsweredQuestions = event.checkLeftAnswer
          ? questionAnswers
              .where((element) => element.isRequired && element.answer == null)
              .toList()
          : [];
      if (notAnsweredQuestions.isNotEmpty) {
        emit(SnackbarMessageAssessmentState(
            "Please answer for ${notAnsweredQuestions.first.question}"));
      } else {
        final answers = questionAnswers
            .where((element) => element.answer?.isNotEmpty ?? false)
            .map((e) => e.toAssessmentRequest())
            .toList();
        emit(SavingAnswersLoadingState());
        final score = await repo
            .saveAssessmentAnswers(answers, _secondsTook ~/ 60)
            .catchError((error) {
          emit(SnackbarMessageAssessmentState('Something went wrong!!'));
          emit(ScoreCalculatedAssessmentState());
          return Future<AssessmentScoreModel>.error(error);
        });
        selectedAssessment?.userScored = score;
        emit(ScoreCalculatedAssessmentState());
      }
    });

    on((StartQuestionCountDownTimerAssessmentEvent event, emit) {
      _timer?.cancel();
      _secondsTook = 0;
      for (var element in questionAnswers) {
        element.answer = null;
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _secondsTook += 1;
        if ((_secondsTook ~/ 60) >= (selectedAssessment?.duration ?? 1)) {
          timer.cancel();
          add(SaveAssessmentAnswersEvent(false));
        } else {
          add(UpdateTimerValueEvent(timeLeft()));
        }
      });
    });

    on((UpdateTimerValueEvent event, emit) =>
        emit(TimerUpdateAssessmentState(event.timeLeft)));
  }
}
