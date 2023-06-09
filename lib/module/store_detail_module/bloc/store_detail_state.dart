part of 'store_detail_bloc.dart';

@immutable
abstract class StoreDetailState {}

class StoreDetailInitial extends StoreDetailState {}

class MarkingLoadingStoreDetailState extends StoreDetailState {}

class MarkingLoadedStoreDetailState extends StoreDetailState {}

class LoadedStoreDetailState extends StoreDetailState {}

class StoreDetailToastMessageState extends StoreDetailState {
  final String message;
  StoreDetailToastMessageState(this.message);
}

class CompaignsLoadedStoreDetailState extends StoreDetailState {}

class LoadedFeedbackState extends StoreDetailState {}
