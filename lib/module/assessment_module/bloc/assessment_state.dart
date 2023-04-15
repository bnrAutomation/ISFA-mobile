part of 'assessment_bloc.dart';

@immutable
abstract class AssessmentState {}

class AssessmentInitial extends AssessmentState {}

class AssessmentListLoadingState extends AssessmentState {}

class AssessmentListLoadedState extends AssessmentState {}
