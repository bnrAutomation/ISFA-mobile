import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/device_registration_module/device_unauthorized_dialog.dart';
import 'package:i_densfa/module/login_verify_module/pinLogin/pin_login_bloc.dart';
import 'package:i_densfa/module/login_verify_module/pin_login_repository.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:upgrader/upgrader.dart';

class PinLoginView extends StatefulWidget {
  const PinLoginView({super.key});
  @override
  State<PinLoginView> createState() => _PinLoginViewState();
}

class _PinLoginViewState extends State<PinLoginView> {
  final otpTextFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: Scaffold(
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
            SafeArea(
              child: Align(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: RepositoryProvider(
                    create: (context) => PinLoginRepository(),
                    child: BlocProvider(
                      create: (context) => PinLoginBloc(context.read()),
                      child: BlocConsumer<PinLoginBloc, PinLoginState>(
                        listenWhen: (previous, current) =>
                            current is PinLoginTokenExpiredState ||
                            current is PinLoginDeviceUnauthorizedState,
                        listener: (context, state) {
                          if (state is PinLoginDeviceUnauthorizedState) {
                            showDeviceUnauthorizedDialog(
                              context,
                              username: state.username,
                              message: state.message,
                            );
                            return;
                          }
                          AppStorage().logout();
                          context.go(AppPaths.login);
                        },
                        buildWhen: (previous, current) =>
                            current is! PinLoginTokenExpiredState,
                        builder: (context, state) {
                          var bloc = context.read<PinLoginBloc>();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(child: contentView(bloc, state)),
                              TextButton(
                                  onPressed: () =>
                                      context.pushReplacement(AppPaths.login),
                                  child: Text(
                                    "Login instead?",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400),
                                  )),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentView(PinLoginBloc bloc, PinLoginState state) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 1.sh),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(ImageConstants.denSfa),
            SizedBox(height: 20.h),
            Image.asset(ImageConstants.poweredBy),
            SizedBox(height: 30.h),
            Text(
              'Enter Login PIN',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStorage().userDetail?.username ?? "",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (state is PinLogInErrorState)
              Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            Container(
              margin: EdgeInsets.only(top: 5.h, bottom: 15.h),
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: ColorConstants.amber),
                  borderRadius: BorderRadius.circular(30.w)),
              padding: EdgeInsets.all(5.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120.w,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          if (otpTextFieldController.text.length > index) {
                            return const Icon(Icons.circle,
                                color: Colors.black);
                          } else {
                            return const Icon(Icons.radio_button_off,
                                color: Colors.black);
                          }
                        }).toList()),
                  ),
                  TextField(
                    maxLength: 4,
                    controller: otpTextFieldController,
                    autofocus: true,
                    enableInteractiveSelection: false,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    showCursor: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    style: const TextStyle(color: Colors.transparent),
                    onChanged: (value) {
                      setState(() {});
                      if (value.length == 4) {
                        context.hideKeyboard();
                      }
                    },
                  )
                ],
              ),
            ),
            BlocListener<PinLoginBloc, PinLoginState>(
              listener: (context, state) {
                if (state is LoginedSuccesfullState) {
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) {
                      context.hideKeyboard();
                      context.go(AppPaths.tabbar);
                    }
                  });
                }
              },
              child: CustomButton(
                buttonText: "ENTER",
                onPressed: () {
                  if (state is! PinLoginLoadingState) {
                    bloc.add(VerifyPinEvent(otpTextFieldController.text));
                  }
                },
                isLoading: state is PinLoginLoadingState,
                isSuccess: state is LoginedSuccesfullState,
              ),

              // MaterialButton(
              //     minWidth: double.maxFinite,
              //     color: ColorConstants.amber,
              //     padding: EdgeInsets.symmetric(vertical: 10.h),
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(50.w)),
              //     onPressed: () {
              // if (state is! PinLoginLoadingState) {
              //   bloc.add(VerifyPinEvent(otpTextFieldController.text));
              // }
              //     },
              //     child: Text(
              //       state is PinLoginLoadingState ? "Loading..." : 'ENTER',
              //       style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
              //     )),
            ),
          ],
        ),
      ),
    );
  }
}
