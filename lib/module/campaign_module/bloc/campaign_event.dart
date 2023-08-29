part of 'campaign_bloc.dart';

abstract class CampaignEvent {}

class GetStoreCampaignsEvent extends CampaignEvent {}

class GetCampaignSections extends CampaignEvent {
  final String campUuId;

  GetCampaignSections(this.campUuId);
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

class AnswerUpdatedCampaignEvent extends CampaignEvent {}
