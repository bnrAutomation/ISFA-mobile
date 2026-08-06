import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.onSurface,
      body: Stack(
        children: [
          Positioned.fill(
              child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    ImageConstants.pinBack,
                    fit: BoxFit.cover,
                  ))),
          Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.6))),
          Positioned(
              bottom: 20,
              right: 20,
              left: 20,
              child: SizedBox(
                width: 1.sw,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: MaterialButton(
                      minWidth: double.maxFinite,
                      color: ColorConstants.amber,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.w)),
                      onPressed: () {
                        context.go(AppPaths.login);
                      },
                      child: Text(
                        "Get Start",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w400),
                      )),
                ),
              )),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(ImageConstants.denSfa),
                const Text(
                  "Sales Force Automation",
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: ColorConstants.amber),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
