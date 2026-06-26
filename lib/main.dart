import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/credential_storage.dart';
import 'package:i_densfa/utility/push_notification_manager.dart';
import 'package:i_densfa/utility/services/global_offline_sync_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:upgrader/upgrader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      final tracesSampleRate = double.tryParse(
        const String.fromEnvironment(
          'SENTRY_TRACES_SAMPLE_RATE',
          defaultValue: '0',
        ),
      ) ??
          0.0;

      final replaySessionSampleRate = double.tryParse(
        const String.fromEnvironment(
          'SENTRY_REPLAY_SESSION_SAMPLE_RATE',
          defaultValue: '0',
        ),
      ) ??
          0.0;

      final replayOnErrorSampleRate = double.tryParse(
        const String.fromEnvironment(
          'SENTRY_REPLAY_ONERROR_SAMPLE_RATE',
          defaultValue: '1',
        ),
      ) ??
          1.0;

      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.environment =
          const String.fromEnvironment('SENTRY_ENV', defaultValue: 'dev');
      options.tracesSampleRate = tracesSampleRate;
      options.replay.sessionSampleRate = replaySessionSampleRate;
      options.replay.onErrorSampleRate = replayOnErrorSampleRate;
      options.privacy.maskAllText = false;
      options.privacy.maskAllImages = false;
      options.privacy.maskAssetImages = false;
      options.sendDefaultPii = false;
    },
    appRunner: () async {
      await AppStorage.objectValue();
      await CredentialStorage.ensureInitialized();
      await GlobalOfflineSyncService.instance.init();

      runApp(
        SentryWidget(
          child: const MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final pushnotification = PushNotificationsManager();
    if (Platform.isAndroid) {
      pushnotification.initAndroid(context);
    } else if (Platform.isIOS) {
      pushnotification.initIos(context);
    }
    return ScreenUtilInit(builder: (context, child) {
      return MaterialApp.router(
        routerConfig: router,
        title: 'iSFA',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return UpgradeAlert(
            upgrader:
                Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
            shouldPopScope: () => false,
            showIgnore: false,
            showLater: false,
            navigatorKey: router.routerDelegate.navigatorKey,
            child: child ?? const Text('Not Found'),
          );
        },
        theme: AppConstant.lightTheme,
        darkTheme: AppConstant.darkTheme,
        themeMode: ThemeMode.light,
      );
    });
  }
}
