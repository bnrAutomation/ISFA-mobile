import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/network_helper.dart';
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
    BuildContext? networkAlertContext;

    return ScreenUtilInit(builder: (context, child) {
      return BlocProvider(
        create: (context) => NetworkBloc()..add(NetworkObserve()),
        child: BlocListener<NetworkBloc, NetworkState>(
          listener: (context, state) {
            if (state is NetworkFailure) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) {
                    networkAlertContext = c;
                    return const AlertDialog(
                      content: Text("No Internet Connection"),
                    );
                  });
            } else {
              if (networkAlertContext != null) {
                Navigator.pop(networkAlertContext!);
              }
            }
          },
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: const [
              MonthYearPickerLocalizations.delegate
            ],
            title: const String.fromEnvironment('APP_NAME'),
            debugShowCheckedModeBanner: false,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            themeMode: ThemeMode.light,
          ),
        ),
      );
    });
  }
}
