part of 'promoter_bloc.dart';

@immutable
abstract class PromoterState {}

class PromoterInitial extends PromoterState {}

class PromoterStoreDetailLoadingState extends PromoterState {}

class PromoterStoreDetailLoadedState extends PromoterState {}

class StoreInventoryLoadingState extends PromoterState {}

class StoreInventoryLoadedState extends PromoterState {}

class PromoterToastMessageState extends PromoterState {
  final String message;
  PromoterToastMessageState(this.message);
}

class PromoterPOPMessageState extends PromoterState {
  final String message;
  PromoterPOPMessageState(this.message);
}

class CompaignsLoadedPromoterState extends PromoterState {}

final class TakeMarkinImage extends PromoterState {
  final Position loc;
  TakeMarkinImage(this.loc);
}

final class TakeMarkOutImage extends PromoterState {
  final Position loc;
  TakeMarkOutImage(this.loc);
}

final class ShowSalesMessage extends PromoterState{
  final String message;
  ShowSalesMessage(this.message);
}
final class MoveToFeedBackState extends PromoterState{}