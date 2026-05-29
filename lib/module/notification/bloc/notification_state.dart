part of 'notification_bloc.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationsLoading extends NotificationState {}

/// Emitted after a fetch completes so pull-to-refresh can await completion.
class NotificationsReady extends NotificationState {}
