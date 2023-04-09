part of 'store_detail_bloc.dart';

@immutable
abstract class StoreDetailEvent {}

class GotoCompaignEvent extends StoreDetailEvent {
  final int storeId;
  GotoCompaignEvent(this.storeId);
}
