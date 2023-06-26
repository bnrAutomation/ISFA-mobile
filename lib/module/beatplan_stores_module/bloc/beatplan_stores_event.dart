part of 'beatplan_stores_bloc.dart';

@immutable
abstract class BeatplanStoresEvent {}

class BeatPlanStoresDateChangeEvent extends BeatplanStoresEvent {
  final DateTime date;

  BeatPlanStoresDateChangeEvent(this.date);
}

class BeatPlanStoresUpdateData extends BeatplanStoresEvent {}

class SearchBeatplanStoresEvent extends BeatplanStoresEvent {
  final String searchText;

  SearchBeatplanStoresEvent(this.searchText);
}

class SortBeatplanStoresEvent extends BeatplanStoresEvent {}

class AddBeatPlanDateSelected extends BeatplanStoresEvent {
  final DateTime date;

  AddBeatPlanDateSelected(this.date);
}

class GetAllStoresListEvent extends BeatplanStoresEvent {}

class BeatPlanAddEvent extends BeatplanStoresEvent {}
