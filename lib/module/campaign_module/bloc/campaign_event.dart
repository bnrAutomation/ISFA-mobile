part of 'campaign_bloc.dart';

abstract class CampaignEvent {}

class GetStoreCampaignsEvent extends CampaignEvent {}

class GetQuestionsForCampaign extends CampaignEvent {
  final int id;

  GetQuestionsForCampaign(this.id);
}

class SaveCampaignAnswersEvent extends CampaignEvent {
  final bool checkLeftAnswer;

  SaveCampaignAnswersEvent(this.checkLeftAnswer);
}
