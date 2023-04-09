part of 'myactivity_bloc.dart';

@immutable
abstract class MyActivityEvent {}

class GetActivityEvent extends MyActivityEvent {}

class MyActivityChangeMonth extends MyActivityEvent {
  final DateTime? dateTime;
  MyActivityChangeMonth(this.dateTime);
}
