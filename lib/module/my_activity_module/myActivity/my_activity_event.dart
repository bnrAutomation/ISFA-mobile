part of 'my_activity_bloc.dart';

@immutable
abstract class MyActivityEvent {}

class MyActivityChangeMonth extends MyActivityEvent {
  final DateTime date;
  MyActivityChangeMonth(this.date);
}

class GetMyAcivityEvent extends MyActivityEvent {}
