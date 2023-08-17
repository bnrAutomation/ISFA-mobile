part of 'analytics_bloc.dart';

@immutable
abstract class AnalyticsEvent {}

class AnalyticsDaysChangeEvent extends AnalyticsEvent {
  final int days;
  AnalyticsDaysChangeEvent(this.days);
}

class GetAnalyticsEvent extends AnalyticsEvent {}
