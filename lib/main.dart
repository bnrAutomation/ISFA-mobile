import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/push_notification_manager.dart';

void main() async {
  await AppStorage.objectValue();
  PushNotificationsManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (context, child) {
      return MaterialApp.router(
        routerConfig: router,
        title: 'iSFA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: ColorConstants.amber,
            primary: ColorConstants.amber,
            secondary: ColorConstants.amberFade,
          ),
          appBarTheme: const AppBarTheme(
              color: ColorConstants.amber,
              centerTitle: true,
              elevation: 2,
              foregroundColor: Colors.white,
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
              )),
        ),
      );
    });
  }
}
