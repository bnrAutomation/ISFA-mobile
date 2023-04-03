part of 'feedback_bloc.dart';

@immutable
abstract class FeedbackEvent {}

class ClickImageFeedbackEvent extends FeedbackEvent {}

class SelectPurposeFeedbackEvent extends FeedbackEvent {
  final String purpose;

  SelectPurposeFeedbackEvent(this.purpose);
}

class AddRemarkFeedbackEvent extends FeedbackEvent {
  final String remark;

  AddRemarkFeedbackEvent(this.remark);
}

class FeedbackSaveEvent extends FeedbackEvent {}

class RemoveSelectedImageFeedbackEvent extends FeedbackEvent {}

class FeedbackGetPurposesEvent extends FeedbackEvent {}
