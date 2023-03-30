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
