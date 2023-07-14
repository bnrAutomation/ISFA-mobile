import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  notify(message);
}

class PushNotificationsManager {
  PushNotificationsManager._();
  factory PushNotificationsManager() => _instance;
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();
  bool _initialized = false;
  Future<void> init() async {
    initNotificationChanel();
    if (!_initialized) {
      await Firebase.initializeApp();

      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        } else {
          FirebaseMessaging.instance.getToken().then((value) async {
            AppStorage().token = value;
            if (AppStorage().isLoggedIn()) {
              await submitToken(value ?? "", AppStorage().userDetail?.id ?? -1);
            }
          });
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            notify(message);
          });
        }
      });
      _initialized = true;
    }
  }

  void initNotificationChanel() {
    AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
            channelGroupKey: 'iSFA',
            channelKey: 'iSFA_key',
            channelName: 'iSFA',
            channelDescription: 'Notification channel iSFA',
            importance: NotificationImportance.High,
            defaultColor: Colors.orange,
            ledColor: Colors.white)
      ],
    );
  }

  Future<bool> submitToken(String fcm, int userId) async {
    final body = {"fcm": fcm};
    final response = await put(
        Uri.parse("${URLConstants.updatefcmtoken}/$userId"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }
}

void notify(RemoteMessage message) {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: Random().nextInt(100),
          channelKey: 'iSFA_key',
          title: message.notification?.title ?? "",
          body: message.notification?.body ?? ""));
}
