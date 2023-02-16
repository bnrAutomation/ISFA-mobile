import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/splash_module/splash/splash_bloc.dart';

import '../../utility/image_constants.dart';
import '../login_module/login_view.dart';
import '../ui/background.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocBuilder<SplashBloc, SplashState>(
        bloc: SplashBloc(),
        builder: (context, state) {
          return Stack(
            children: [
              const Background(false),
              Positioned(
                  bottom: 20,
                  right: 20,
                  left: 20,
                  child: SizedBox(
                    width: 1.sw,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MaterialButton(
                        onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => LoginView())))
                        },
                        elevation: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                        splashColor: Colors.red.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        child: const Text(
                          "Get Start",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
              Center(
                child: Image.asset(
                  imageConstants.logo,
                  width: 0.5.sw,
                  height: 0.5.sh,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
