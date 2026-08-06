part of 'survey_bloc.dart';

abstract class SurveyState {}

class SurveyInitial extends SurveyState {}

class OptionChangeState extends SurveyState {}

class SurveyListLoadingState extends SurveyState {}

class SurveyListLoadedState extends SurveyState {}

class SurveyQuestionsLoadedState extends SurveyState {}

class SnackbarMessageSurveyState extends SurveyState {
  final String message;

  SnackbarMessageSurveyState(this.message);
}

class ScoreCalculatedSurveyState extends SurveyState {}

class SavingAnswersLoadingState extends SurveyState {}

class SurveyNavigateState extends SurveyState {
  final String named;

  SurveyNavigateState({required this.named});
}

class SurveyScheduleLoadingState extends SurveyState {}

class SurveyScheduleSuccessState extends SurveyState {}
