import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/notification/notifcation_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  List<NotificationModel> notifcations = [];
  NotificationBloc() : super(NotificationInitial()) {
    on(_onGetNotification);
    add(GetNotificationsEvent());
  }

  void _onGetNotification(
      GetNotificationsEvent event, Emitter<NotificationState> emit) async {
    const url = "${URLConstants.getNotifications}/19";
    emit(NotificationsLoading());
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      try {
        notifcations =
            NotificationResponseModel.fromRawJson(response.body).notifications;
        emit(NotificationInitial());
      } catch (e) {
        debugPrint(e.toString());
        emit(NotificationInitial());
      }
    } else {
      emit(NotificationInitial());
    }
  }
}
