part of 'learner_bloc.dart';

@immutable
abstract class LearnerState {}

class LearnerInitial extends LearnerState {}

class LearnerLoadingState extends LearnerState {}

class LearnerLoadedState extends LearnerState {}

class LearnerToastMessageState extends LearnerState {
  final String errorMessage;
  LearnerToastMessageState(this.errorMessage);
}
