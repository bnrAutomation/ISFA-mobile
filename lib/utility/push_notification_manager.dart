import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:i_densfa/utility/handler.dart';
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
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBs2IXbLsjHLibX4Cie7uoSbz9XsjECQuM",
          appId: "1:950410544983:web:fc358706310adf4807e012",
          messagingSenderId: "950410544983",
          projectId: "isfa-d6459",
        ),
      );
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        } else {
          FirebaseMessaging.instance.getToken().then((value) async {
            AppStorage().fcmToken = value;
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
    final response = await CustomHttpBaseClient().put(
        Uri.parse("${URLConstants.updatefcmtoken}/$userId"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response.body);
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
