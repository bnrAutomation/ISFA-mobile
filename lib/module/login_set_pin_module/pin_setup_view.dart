import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/login_set_pin_module/setPin/set_pin_bloc.dart';
import 'package:i_densfa/module/login_set_pin_module/set_pin_repository.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

class PinSetupView extends StatefulWidget {
  const PinSetupView({super.key});

  @override
  State<PinSetupView> createState() => _PinSetupViewState();
}

class _PinSetupViewState extends State<PinSetupView> {
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned.fill(
                child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      ImageConstants.pinBack,
                      fit: BoxFit.cover,
                    ))),
            Positioned.fill(
                child: ColoredBox(color: Colors.black.withOpacity(0.6))),
            Positioned.fill(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: RepositoryProvider(
                  create: (context) => SetPinRepository(),
                  child: BlocProvider(
                    create: (context) => SetPinBloc(context.read()),
                    child: BlocConsumer<SetPinBloc, SetPinState>(
                      listener: (context, state) {
                        if (state is SetPinedSuccesfullState) {
                          context.showSnackBarMessage(
                              'Successfully set login pin');
                          context.go(AppPaths.tabbar);
                        }
                      },
                      builder: (context, state) {
                        var bloc = context.read<SetPinBloc>();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: SizedBox(
                            width: 1.sw,
                            height: 0.8.sh,
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                // mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(height: 40.h),
                                  Image.asset(ImageConstants.denSfa),
                                  SizedBox(height: 30.h),
                                  Image.asset(ImageConstants.poweredBy),
                                  SizedBox(height: 20.h),
                                  Text(
                                    AppStorage().userDetail?.username ?? "",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Set login pin for easy access in future!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(height: 20.h),
                                  if (state is SetPinErrorState)
                                    Text(
                                      state.errorMessage,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Enter 4 digit pin',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  TextField(
                                    maxLength: 4,
                                    controller: pinController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    autofocus: true,
                                    enableInteractiveSelection: false,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    showCursor: false,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.w),
                                          borderSide: const BorderSide(
                                              color: ColorConstants.amber)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.w),
                                          borderSide: const BorderSide(
                                              color: Colors.white54)),
                                      counterText: '',
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Confirm Pin',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  TextField(
                                    maxLength: 4,
                                    controller: confirmPinController,
                                    enableInteractiveSelection: false,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    showCursor: false,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.w),
                                          borderSide: const BorderSide(
                                              color: ColorConstants.amber)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.w),
                                          borderSide: const BorderSide(
                                              color: Colors.white54)),
                                      counterText: '',
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  MaterialButton(
                                      minWidth: double.maxFinite,
                                      color: ColorConstants.amber,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.w)),
                                      onPressed: () {
                                        bloc.add(MoveSetPinEvent(
                                            pinController.text,
                                            confirmPinController.text));
                                      },
                                      child: Text(
                                        'SUBMIT',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
}
