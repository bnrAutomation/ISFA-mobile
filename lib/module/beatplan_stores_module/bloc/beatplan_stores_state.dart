part of 'beatplan_stores_bloc.dart';

@immutable
abstract class BeatplanStoresState {}

class BeatPlanSnackBarMessage extends BeatplanStoresState {
  final String message;

  BeatPlanSnackBarMessage(this.message);
}

class BeatPlanStoreLoaded extends BeatplanStoresState {}

class BeatPlanStoresLoadingState extends BeatplanStoresState {}

class EmptySearchTextBeatplanStoresState extends BeatplanStoresState {}
