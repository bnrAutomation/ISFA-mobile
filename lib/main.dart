import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'module/splash_module/splash_view.dart';
import 'module/tabber_module/tabber_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeData _darkTheme = ThemeData(
      secondaryHeaderColor: Colors.white70,
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0XFF003D5B),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white)),
      colorScheme: const ColorScheme(
          secondary: Color(0xFF5F39E8),
          onBackground: Colors.black,
          onError: Color(0xFFe74c3c),
          brightness: Brightness.dark,
          onSecondary: Color(0xFF5F39E8),
          onSurface: Color(0xFF232323),
          background: Colors.black,
          onPrimary: Color(0xFFDC6434),
          primary: Color(0xFFDC6434),
          surface: Color(0xFF232323),
          error: Color(0xFFe74c3c)),
      // accentColor: const Color(0xFF5F39E8) ,
      dividerColor: Colors.transparent,
      brightness: Brightness.dark,
      cardColor: const Color(0xFF232323),
      primaryColor: const Color(0xFFDC6434),
      shadowColor: Colors.black54,
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFFDC6434),
        disabledColor: Colors.white,
      ));

  final ThemeData _lightTheme = ThemeData(
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0XFF003D5B),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white)),
    // secondaryHeaderColor: Colors.black87,
    // colorScheme: const ColorScheme(
    //     secondary: Color(0xFFF900A7),
    //     onBackground: Colors.white,
    //     onError: Color(0xFFe74c3c),
    //     brightness: Brightness.light,
    //     onSecondary: Color(0xFFF900A7),
    //     onSurface: Color(0xFFFFFBFA),
    //     background: Colors.white,
    //     onPrimary: Color(0xFFDC6434),
    //     primary: Color(0xFFDC6434),
    //     surface: Color(0xFFFFFBFA),
    //     error: Color(0xFFe74c3c)),
    // dividerColor: Colors.transparent,
    // brightness: Brightness.light,
    // cardColor: const Color(0xFFF8F8F8),
    // primaryColor: const Color(0xFFDC6434),
    // shadowColor: Colors.grey[400],
    // buttonTheme: const ButtonThemeData(
    //   buttonColor: Color(0xFFDC6434),
    //   disabledColor: Colors.white,
    // ),
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        builder: (context, child) => MaterialApp(
              title: 'iDenSFA',
              debugShowCheckedModeBanner: false,
              theme: _lightTheme,
              darkTheme: _darkTheme,
              themeMode: ThemeMode.light,
              home: const TabberView(),
            ));
  }
}
