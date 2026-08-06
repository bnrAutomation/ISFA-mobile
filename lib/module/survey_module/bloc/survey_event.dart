part of 'survey_bloc.dart';

abstract class SurveyEvent {}

class SurveyClientNameAdded extends SurveyEvent {
  final String name;
  XFile? clientfile;

  SurveyClientNameAdded({required this.name, this.clientfile});
}

class SurveyListSearchEvent extends SurveyEvent {
  final String seachText;

  SurveyListSearchEvent({required this.seachText});
}

class SurveyVisitsDateChangeEvent extends SurveyEvent {
  final DateTime date;

  SurveyVisitsDateChangeEvent({required this.date});
}

class CreateNotesEvent extends SurveyEvent {
  final String comment;

  CreateNotesEvent({required this.comment});
}

class GetNotesEvent extends SurveyEvent {}

class DeleteNotesEvent extends SurveyEvent {
  final int noteId;
  DeleteNotesEvent(this.noteId);
}

class GetSurveyVisitEvent extends SurveyEvent {}

class CreateSurveyVisitEvent extends SurveyEvent {
  final String clientName;
  final DateTime visitDate;
  final String agenda;

  CreateSurveyVisitEvent(this.clientName, this.visitDate, this.agenda);
}

class GetClientEvent extends SurveyEvent {}

class GetSurveysEvent extends SurveyEvent {}

class ChangeStateEvent extends SurveyEvent {}

class GetSurveySections extends SurveyEvent {
  final String surveyUuId;

  GetSurveySections(this.surveyUuId);
}

class GetQuestionsForSection extends SurveyEvent {
  final String sectionUuId;

  GetQuestionsForSection({required this.sectionUuId});
}

class SaveSurveyAnswersEvent extends SurveyEvent {}

class AnswerUpdatedSurveyEvent extends SurveyEvent {
  final String question;
  final String answer;
  AnswerUpdatedSurveyEvent(this.question, this.answer);
}

class UploadImageEvent extends SurveyEvent {
  final String questionUuid;
  final String path;
  final bool isIssue;
  UploadImageEvent(this.questionUuid, this.path, this.isIssue);
}

class SnackbarMessageSurveyEvent extends SurveyEvent {
  final String message;

  SnackbarMessageSurveyEvent({required this.message});
}

class CompleteSurveyFormEvent extends SurveyEvent {
  final bool editPrevious;

  CompleteSurveyFormEvent({required this.editPrevious});
}

class GetSavedAnswersEvent extends SurveyEvent {
  final String sectionUuid;

  GetSavedAnswersEvent({required this.sectionUuid});
}

class GetFilledSurveysEvent extends SurveyEvent {
  final String surveyUuid;

  GetFilledSurveysEvent({required this.surveyUuid});
}

class GetNextFilledSurveysEvent extends SurveyEvent {
  final String surveyUuid;

  GetNextFilledSurveysEvent({required this.surveyUuid});
}

// class ChangeFilterValueEvent extends SurveyEvent {
//   ChangeFilterValueEvent();
// }
