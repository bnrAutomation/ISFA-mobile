part of 'campaign_bloc.dart';

abstract class CampaignState {}

class CampaignInitial extends CampaignState {}

class CampaignListLoadingState extends CampaignState {}

class CampaignListLoadedState extends CampaignState {}

class CampaignQuestionsLoadedState extends CampaignState {}

class SnackbarMessageCampaignState extends CampaignState {
  final String message;

  SnackbarMessageCampaignState(this.message);
}

class ScoreCalculatedCampaignState extends CampaignState {}

class SavingAnswersLoadingState extends CampaignState {}
