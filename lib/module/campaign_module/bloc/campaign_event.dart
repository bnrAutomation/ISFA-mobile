part of 'campaign_bloc.dart';

abstract class CampaignEvent {}

class GetStoreCampaignsEvent extends CampaignEvent {}

class GetCampaignSections extends CampaignEvent {
  final String campUuId;

  GetCampaignSections(this.campUuId);
}

class GetQuestionsForSection extends CampaignEvent {
  final String campUuId;
  final String sectionUuId;

  GetQuestionsForSection({required this.campUuId, required this.sectionUuId});
}

class SaveCampaignAnswersEvent extends CampaignEvent {
  final bool checkLeftAnswer;

  SaveCampaignAnswersEvent(this.checkLeftAnswer);
}

class GetSavedCampaignResponseEvent extends CampaignEvent {
  final int campaignId;

  GetSavedCampaignResponseEvent(this.campaignId);
}
