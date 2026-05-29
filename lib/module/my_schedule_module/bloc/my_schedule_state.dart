part of 'my_schedule_bloc.dart';

@immutable
abstract class MyScheduleState {}

class MyScheduleSnackBarMessage extends MyScheduleState {
  final String message;

  MyScheduleSnackBarMessage(this.message);
}

class BeatPlanStoreLoaded extends MyScheduleState {}

class MyScheduleLoadingState extends MyScheduleState {}

class EmptySearchTextMyScheduleState extends MyScheduleState {}

class StoreListLoadedState extends MyScheduleState {}

class MechanicListLoadedState extends MyScheduleState {}

class BeatPlanUploadLoadingState extends MyScheduleState {}

class BeatPlanUploadSuccess extends MyScheduleState {}

class AddBeatPlanDateSelectedState extends MyScheduleState {}
class StateChangeData extends MyScheduleState{}