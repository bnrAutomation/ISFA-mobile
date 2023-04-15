part of 'assessment_bloc.dart';

@immutable
abstract class AssessmentEvent {}

class AssessmentTouchChanged extends AssessmentEvent {
  final int index;

  AssessmentTouchChanged(this.index);
}

class GetUserAssessmentsEvent extends AssessmentEvent {}

class GetQuestionsForAssessment extends AssessmentEvent {
  final int id;

  GetQuestionsForAssessment(this.id);
}

class SaveAssessmentAnswersEvent extends AssessmentEvent {
  final bool checkLeftAnswer;

  SaveAssessmentAnswersEvent(this.checkLeftAnswer);
}

class StartQuestionCountDownTimerAssessmentEvent extends AssessmentEvent {}

class UpdateTimerValueEvent extends AssessmentEvent {
  final String timeLeft;

  UpdateTimerValueEvent(this.timeLeft);
}
