part of 'campaign_bloc.dart';

abstract class CampaignState {}

class CampaignInitial extends CampaignState {}

class OptionChangeState extends CampaignState {}

class CampaignListLoadingState extends CampaignState {}

class CampaignListLoadedState extends CampaignState {}

class CampaignQuestionsLoadedState extends CampaignState {}
class CampaignQuestionsLoadedForState extends CampaignState {}
class SnackbarMessageCampaignState extends CampaignState {
  final String message;

  SnackbarMessageCampaignState(this.message);
}

class ScoreCalculatedCampaignState extends CampaignState {}

class SavingAnswersLoadingState extends CampaignState {}

class SagmentAddSuccessfully extends CampaignState {}

class SyncingOfflineDataState extends CampaignState {
  final int pendingCount;
  SyncingOfflineDataState(this.pendingCount);
}

class OfflineSubmissionQueuedState extends CampaignState {
  final String submissionId;
  final int totalPending;
  OfflineSubmissionQueuedState(this.submissionId, this.totalPending);
}
