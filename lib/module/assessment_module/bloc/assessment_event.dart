part of 'assessment_bloc.dart';

@immutable
abstract class AssessmentEvent {}

class AssessmentTouchChanged extends AssessmentEvent {
  final int index;

  AssessmentTouchChanged(this.index);
}
