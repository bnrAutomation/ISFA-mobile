part of 'campaign_bloc.dart';

abstract class CampaignEvent {}

class GetStoreCampaignsEvent extends CampaignEvent {
  final String storeId;
  final String mechanicsName;
  final String retailerName; 
  GetStoreCampaignsEvent(this.storeId,this.mechanicsName,this.retailerName);
}

class GetFilledCampaignsEvent extends CampaignEvent {
  final String storeId;
  GetFilledCampaignsEvent(this.storeId);
}

class ChangeStateEvent extends CampaignEvent {}

class GetCampaignSections extends CampaignEvent {
  final String campUuId;
  final int index;
  GetCampaignSections(this.campUuId,this.index);
}


class GetCampaignSectionsFirstTime extends CampaignEvent {
  final String campUuId;
  final int index;
  GetCampaignSectionsFirstTime(this.campUuId,this.index);
}


class GetQuestionsForSectionFirstTime extends CampaignEvent {
  final String sectionUuId;
  GetQuestionsForSectionFirstTime({required this.sectionUuId});
}

class GetQuestionsForSection extends CampaignEvent {
  final String sectionUuId;
  GetQuestionsForSection({required this.sectionUuId});
}

class SaveCampaignAnswersEvent extends CampaignEvent {
  final bool checkLeftAnswer;
  SaveCampaignAnswersEvent(this.checkLeftAnswer);
}

class GetSavedCampaignResponseEvent extends CampaignEvent {
  final String campUuid;
  GetSavedCampaignResponseEvent(this.campUuid);
}

class AnswerUpdatedCampaignEvent extends CampaignEvent {
  final String question;
  final String sectionName;
  final int index;
  final int orderIndex;
  AnswerUpdatedCampaignEvent(this.question, this.sectionName, this.index,this.orderIndex);
}

class UploadImageEvent extends CampaignEvent {
  final String questionUuid;
  final String path;
  final bool isIssue;
  final int index ;
  final int sagmentIndex;
  UploadImageEvent(this.questionUuid, this.path, this.isIssue,this.index,this.sagmentIndex);
}

class SnackbarMessageCampaignEvent extends CampaignEvent {
  final String message;

  SnackbarMessageCampaignEvent({required this.message});
}

class AddSagmentEvent extends CampaignEvent {
  final List<QuestionModel> questionAnswers;
  AddSagmentEvent(this.questionAnswers);
}


class AddProductSagmentEvent extends CampaignEvent {
  final List<QuestionModel> questionAnswers;
  AddProductSagmentEvent(this.questionAnswers);
}


class AddStockEvent extends CampaignEvent {
  final List<QuestionModel> questionAnswers;
  AddStockEvent(this.questionAnswers);
}


class AddFixtureAuditEvent extends CampaignEvent {
  final List<QuestionModel> questionAnswers;
  AddFixtureAuditEvent(this.questionAnswers);
}

class AddDemoAuditEvent extends CampaignEvent {
  final List<QuestionModel> questionAnswers;
  AddDemoAuditEvent(this.questionAnswers);
}

class AddQtySagmentEvent extends CampaignEvent {
  final List<QuestionModel> questionAnswers;
  AddQtySagmentEvent(this.questionAnswers);
}

class AddGiftSagmentEvent extends CampaignEvent {
  final List<QuestionModel> questionAnswers;
  AddGiftSagmentEvent(this.questionAnswers);
}

class AddAnotherSoldSagmentEvent extends CampaignEvent {
  final List<QuestionModel> questionAnswers;
  AddAnotherSoldSagmentEvent(this.questionAnswers);
}

class SyncOfflineSubmissionsEvent extends CampaignEvent {}

class PreSyncCampaignsForStoreEvent extends CampaignEvent {
  final String storeId;
  PreSyncCampaignsForStoreEvent(this.storeId);
}
