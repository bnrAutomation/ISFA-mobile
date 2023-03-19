import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/splash_module/splash_view.dart';
import 'package:month_year_picker/month_year_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeData _darkTheme = ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: ThemeData.light(useMaterial3: true).colorScheme.copyWith(
          primary: const Color(0XFF003D5B),
          onPrimary: const Color(0XFFFFBF00),
          onBackground: const Color(0xFF232323)),
      primaryColor: const Color(0XFF003D5B),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0XFFFFBF00),
        disabledColor: Colors.white,
      ));

  final ThemeData _lightTheme = ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: ThemeData.light(useMaterial3: true).colorScheme.copyWith(
            primary: const Color(0XFF003D5B),
            onPrimary: const Color(0XFFFFBF00),
            background: const Color(0xFFF8F8F8),
          ),
      primaryColor: const Color(0XFF003D5B),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0XFFFFBF00),
        disabledColor: Colors.white,
      ));

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        builder: (context, child) => MaterialApp(
              localizationsDelegates: const [
                MonthYearPickerLocalizations.delegate,
              ],
              title: 'iDenSFA',
              debugShowCheckedModeBanner: false,
              theme: _lightTheme,
              darkTheme: _darkTheme,
              themeMode: ThemeMode.light,
              home: const SplashView(),
            ));
  }
}
