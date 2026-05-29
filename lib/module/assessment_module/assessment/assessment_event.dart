part of 'assessment_bloc.dart';

@immutable
sealed class AssessmentEvent {}

final class GetAssessmentEvent extends AssessmentEvent {}

final class GetAssessmentLevel extends AssessmentEvent {
  final AssessmentListItemModel item;
  GetAssessmentLevel(this.item);
}

final class GetSectionEvent extends AssessmentEvent {
  final AssessmentLevel item;
  GetSectionEvent(this.item);
}

final class GetQuestionsForSection extends AssessmentEvent {
  final String sectionUuId;
  GetQuestionsForSection(this.sectionUuId);
}

final class AnswerUpdatedAssessmentEvent extends AssessmentEvent {
  final String question;
  AnswerUpdatedAssessmentEvent(this.question);
}

final class SaveAssessmentAnswersEvent extends AssessmentEvent {
  final bool checkLeftAnswer;
  SaveAssessmentAnswersEvent(this.checkLeftAnswer);
}

final class UpdateTimerValueEvent extends AssessmentEvent {
  final String timeLeft;
  UpdateTimerValueEvent(this.timeLeft);
}

class UploadImageEvent extends AssessmentEvent {
  final String questionUuid;
  final String path;
  final bool isIssue;
  UploadImageEvent(this.questionUuid, this.path, this.isIssue);
}

final class StartQuestionCountDownTimerAssessmentEvent
    extends AssessmentEvent {}
