part of 'my_activity_bloc.dart';

@immutable
abstract class MyActivityState {}

class MyActivityInitial extends MyActivityState {}

class MyActivityShowSnack extends MyActivityState {
  final String message;
  MyActivityShowSnack(this.message);
}

class MyAcivityMonthChangeState extends MyActivityState {}

class MyActivityLoadingState extends MyActivityState {}

class MyActivityWithData extends MyActivityState {}
