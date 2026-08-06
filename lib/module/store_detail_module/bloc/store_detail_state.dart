part of 'store_detail_bloc.dart';

@immutable
abstract class StoreDetailState {}

class StoreDetailInitial extends StoreDetailState {}

class LoadingStoreDetailState extends StoreDetailState {}

class MarkingLoadingStoreDetailState extends StoreDetailState {}

class MarkingLoadedStoreDetailState extends StoreDetailState {}

class LoadedStoreDetailState extends StoreDetailState {}

class StoreDetailToastMessageState extends StoreDetailState {
  final String message;
  StoreDetailToastMessageState(this.message);
}

class CampaignsLoadedStoreDetailState extends StoreDetailState {}

class LoadedFeedbackState extends StoreDetailState {}

final class StoreDetailTakeMarkinImage extends StoreDetailState {}

final class StoreDetailTakeMarkOutImage extends StoreDetailState {}

final class ChangeState extends StoreDetailState {}

class AddCampaignFetchLoadingState extends StoreDetailState {}

class AddCampaignSubmitLoadingState extends StoreDetailState {}

class AddCampaignLoadedStoreDetailState extends StoreDetailState {
  final List<AllCampaignModel> campaigns;
  AddCampaignLoadedStoreDetailState(this.campaigns);
}

class AddCampaignFetchErrorState extends StoreDetailState {
  final String message;
  AddCampaignFetchErrorState(this.message);
}

class AddCampaignSubmitErrorState extends StoreDetailState {
  final String message;
  AddCampaignSubmitErrorState(this.message);
}

class AddCampaignSuccessStoreDetailState extends StoreDetailState {}
