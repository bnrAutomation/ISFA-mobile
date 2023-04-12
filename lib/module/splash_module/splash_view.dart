import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import '../ui/background.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
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
                      onPressed: () => context.go(AppPaths.login),
                      buttonText: "Get Start",
                    )),
              )),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  ImageConstants.logo,
                  // width: 0.5.sw,
                  // height: 0.5.sh,
                ),
                // const Text(
                //   "Sales Force Automation",
                //   style: TextStyle(fontStyle: FontStyle.italic),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
