import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/push_notification_manager.dart';

void main() async {
  await AppStorage.objectValue();
  PushNotificationsManager().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeData _darkTheme = ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: ThemeData.light(useMaterial3: true).colorScheme.copyWith(
          primary: const Color(0XFF003D5B),
          onPrimary: ColorConstants.amber,
          onBackground: const Color(0xFF232323)),
      primaryColor: const Color(0XFF003D5B),
      buttonTheme: const ButtonThemeData(
        buttonColor: ColorConstants.amber,
        disabledColor: Colors.white,
      ));

  final ThemeData _lightTheme = ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: ThemeData.light(useMaterial3: true).colorScheme.copyWith(
            primary: const Color(0XFF003D5B),
            onPrimary: ColorConstants.amber,
            background: const Color(0xFFF8F8F8),
          ),
      primaryColor: const Color(0XFF003D5B),
      buttonTheme: const ButtonThemeData(
        buttonColor: ColorConstants.amber,
        disabledColor: Colors.white,
      ));

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (context, child) {
      return MaterialApp.router(
        routerConfig: router,
        title: const String.fromEnvironment('APP_NAME'),
        debugShowCheckedModeBanner: false,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: ThemeMode.light,
      );
    });
  }
}
