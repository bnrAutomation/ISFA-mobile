part of 'myactivity_bloc.dart';

@immutable
abstract class MyActivityState {}

class MyActivityInitial extends MyActivityState {}

class MyAcivityMonthChangeState extends MyActivityState {}

class MyAcivityLoadingState extends MyActivityState {}

class MyActivityWithData extends MyActivityState {}

class MyActivityShowSnack extends MyActivityState {
  final String message;
  MyActivityShowSnack(this.message);
}
