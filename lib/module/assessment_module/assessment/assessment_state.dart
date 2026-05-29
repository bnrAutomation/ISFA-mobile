part of 'assessment_bloc.dart';

@immutable
sealed class AssessmentState {}

final class AssessmentInitial extends AssessmentState {}

final class AssessmentListLoadingState extends AssessmentState {}

final class AssessmentListLoadedState extends AssessmentState {}

final class SnackbarMessageState extends AssessmentState {
  final String message;
  SnackbarMessageState(this.message);
}

final class AssessmentQuestionsLoadedState extends AssessmentState {}

final class SavingAnswersLoadingState extends AssessmentState {}

final class OptionChangeState extends AssessmentState {}

final class ScoreCalculatedAssessmentState extends AssessmentState {}

final class TimerUpdateAssessmentState extends AssessmentState {
  final String leftTime;
  TimerUpdateAssessmentState(this.leftTime);
}
