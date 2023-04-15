part of 'assessment_bloc.dart';

@immutable
abstract class AssessmentState {}

class AssessmentInitial extends AssessmentState {}

class AssessmentListLoadingState extends AssessmentState {}

class AssessmentListLoadedState extends AssessmentState {}

class AssessmentQuestionsLoadedState extends AssessmentState {}

class SnackbarMessageAssessmentState extends AssessmentState {
  final String message;

  SnackbarMessageAssessmentState(this.message);
}

class ScoreCalculatedAssessmentState extends AssessmentState {}

class SavingAnswersLoadingState extends AssessmentState {}

class TimerUpdateAssessmentState extends AssessmentState {
  final String leftTime;

  TimerUpdateAssessmentState(this.leftTime);
}
