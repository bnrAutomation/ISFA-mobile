part of 'promoter_bloc.dart';

@immutable
abstract class PromoterEvent {}

class GetInventoryDetailEvent extends PromoterEvent {}

class GetStoreDetailEvent extends PromoterEvent {}

class SearchByNamePromoterEvent extends PromoterEvent {
  final String name;

  SearchByNamePromoterEvent(this.name);
}

class PromoterShowToastMessageEvent extends PromoterEvent {
  final String message;

  PromoterShowToastMessageEvent(this.message);
}

class PromoterCheckInStoreEvent extends PromoterEvent {}

class PromoterCheckOutStoreEvent extends PromoterEvent {}

class GoToMapPromoterEvent extends PromoterEvent {}

class GotoCompaignEvent extends PromoterEvent {}
