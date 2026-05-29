part of 'feedback_bloc.dart';

@immutable
abstract class FeedbackState {}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoadingState extends FeedbackState {}

class FeedbackSuccessState extends FeedbackState {}

class FeedbackErrorState extends FeedbackState {
  final String errorMessage;

  FeedbackErrorState(this.errorMessage);
}
