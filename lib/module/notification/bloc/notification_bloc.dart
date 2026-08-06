import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/notification/notifcation_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  List<NotificationModel> notifcations = [];
  int userId = AppStorage().userDetail?.id ?? 1;
  NotificationBloc() : super(NotificationInitial()) {
    on(_onGetNotification);
    add(GetNotificationsEvent());
  }

  void _onGetNotification(
      GetNotificationsEvent event, Emitter<NotificationState> emit) async {
    String url = "${URLConstants.getNotifications}/$userId";
    // Avoid full-screen loader on refresh when list already has items.
    if (notifcations.isEmpty) {
      emit(NotificationsLoading());
    }
    final response = await CustomHttpBaseClient.instance.get(Uri.parse(url));
    if (response.statusCode == 200) {
      try {
        notifcations =
            NotificationResponseModel.fromRawJson(response.body).notifications;
        AppConstant.notificationCount = 0;
        emit(NotificationsReady());
      } catch (e) {
        emit(NotificationsReady());
      }
    } else {
      emit(NotificationsReady());
    }
  }
}
