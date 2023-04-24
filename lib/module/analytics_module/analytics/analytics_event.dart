part of 'analytics_bloc.dart';

@immutable
abstract class AnalyticsEvent {}

class AnalyticsUpdateDataEvent extends AnalyticsEvent {}

class AnalyticsDateChangeEvent extends AnalyticsEvent {
  final DateTime date;
  AnalyticsDateChangeEvent(this.date);
}
