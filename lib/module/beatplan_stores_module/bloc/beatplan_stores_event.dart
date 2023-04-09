part of 'beatplan_stores_bloc.dart';

@immutable
abstract class BeatplanStoresEvent {}

class BeatPlanStoresDateChangeEvent extends BeatplanStoresEvent {
  final DateTime date;

  BeatPlanStoresDateChangeEvent(this.date);
}

class BeatPlanStoresUpdateData extends BeatplanStoresEvent {}
