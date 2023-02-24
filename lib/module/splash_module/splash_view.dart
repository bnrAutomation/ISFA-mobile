import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/splash_module/splash/splash_bloc.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';
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
                        child: CustomMaterialButton(
                          onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => LoginView())))
                          },
                          buttonText: "Get Start",
                        )),
                  )),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      imageConstants.logo,
                      // width: 0.5.sw,
                      // height: 0.5.sh,
                    ),
                    const Text(
                      "Sales Force Automation",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
