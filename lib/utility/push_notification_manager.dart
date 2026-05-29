import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_broadcast_receiver/flutter_broadcast_receiver.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/firebase_options.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  AppConstant.notificationCount++;
  await Firebase.initializeApp();
  notify(message);
}

class PushNotificationsManager {
  PushNotificationsManager._();
  factory PushNotificationsManager() => _instance;
  static final PushNotificationsManager _instance =
      PushNotificationsManager._();
  bool _initialized = false;

  Future<void> initIos(BuildContext context) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return;
    }
    final String? token = await messaging.getToken();
    if (token != null) {
      AppStorage().fcmToken = token;
      await submitToken(token, AppStorage().userDetail?.id);
    }
  }

  Future<void> initAndroid(BuildContext context) async {
    initNotificationChanel();
    if (!_initialized) {
      try {
        await Firebase.initializeApp(
          name: "isfa",
          options: const FirebaseOptions(
            apiKey: "AIzaSyBs2IXbLsjHLibX4Cie7uoSbz9XsjECQuM",
            appId: "1:950410544983:web:fc358706310adf4807e012",
            messagingSenderId: "950410544983",
            projectId: "isfa-d6459",
          ),
        );
      } catch (e, _) {
        if (kDebugMode) {
          debugPrint('$e');
        }
      }
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
          allowNotificatin(context);
        } else {
          allowNotificatin(context);
        }
      });
      _initialized = true;
    }
  }

  void allowNotificatin(BuildContext context) {
    FirebaseMessaging.instance.getToken().then((value) async {
      AppStorage().fcmToken = value;
      if (AppStorage().isLoggedIn()) {
        BroadcastReceiver().publish<String>(AppConstant.tokenupdate,arguments: value);
      }
    });
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      notify(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(context, message);
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationClick(context, message);
      }
    });
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

  static Future<bool> submitToken(String fcm, int? userId) async {
    if (userId == null) {
      return false;
    }
    // final pacageInfo = await PackageInfo.fromPlatform();
    String plateform = Platform.isAndroid
        ? "android"
        : Platform.isIOS
            ? 'ios'
            : 'other';
    final body = {"fcm": fcm, 'appversion': "", "device": plateform};

    final response = await CustomHttpBaseClient.instance.put(
        Uri.parse("${URLConstants.updatefcmtoken}/$userId"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    return response.statusCode == 200;
  }
}

void notify(RemoteMessage message) {
  AppConstant.notificationCount++;
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: Random().nextInt(100),
          channelKey: 'iSFA_key',
          title: message.notification?.title ?? "",
          body: message.notification?.body ?? ""));
}

// Handling a notification click event by navigating to the specified screen
void _handleNotificationClick(BuildContext context, RemoteMessage message) {
  final notificationData = message.data;
  if (notificationData.containsKey('ticketId')) {
    final ticketId = notificationData['ticketId'];
    context.pushNamed(AppPaths.issuesDetail, extra: ticketId);
  }
}
