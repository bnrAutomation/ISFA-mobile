part of 'mystore_bloc.dart';

@immutable
sealed class MystoreEvent {}

class MyStoreUpdateData extends MystoreEvent {}
class GetNextStoreEvent extends MystoreEvent {}
class SearchMyStoreEvent extends MystoreEvent{
  final String value;
  SearchMyStoreEvent(this.value);
}
class GetNextFilterStoreEvent  extends MystoreEvent{
  final String value;
  GetNextFilterStoreEvent(this.value);
}

class GetNextIssuesEvent extends MystoreEvent{}
class SortMyStoreEvent extends MystoreEvent{}
class GetCampaignFilledEvent extends MystoreEvent{
  final BeatPlanModel store;
  GetCampaignFilledEvent(this.store);
}
