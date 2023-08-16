part of 'my_schedule_bloc.dart';

@immutable
abstract class MyScheduleEvent {}

class MyScheduleDateChangeEvent extends MyScheduleEvent {
  final DateTime date;

  MyScheduleDateChangeEvent(this.date);
}

class MyScheduleUpdateData extends MyScheduleEvent {}

class SearchMyScheduleEvent extends MyScheduleEvent {
  final String searchText;

  SearchMyScheduleEvent(this.searchText);
}

class SortMyScheduleEvent extends MyScheduleEvent {}

class AddBeatPlanDateSelected extends MyScheduleEvent {
  final DateTime date;

  AddBeatPlanDateSelected(this.date);
}

class GetAllStoresListEvent extends MyScheduleEvent {}

class BeatPlanAddEvent extends MyScheduleEvent {}
