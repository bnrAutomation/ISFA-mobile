part of 'analytics_bloc.dart';

@immutable
abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsUpdateData extends AnalyticsState {}

class AnalyticsSnackBarMessage extends AnalyticsState {
  final String message;

  AnalyticsSnackBarMessage(this.message);
}

class LoadingState extends AnalyticsState {}
