import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/login_module/bloc/login_bloc.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

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
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) => {},
          builder: (context, state) {
            var bloc = context.read<LoginBloc>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImageConstants.denSfa,
                ),
                SizedBox(height: 15.h),
                Text(
                  AppStorage().userDetail?.username ?? "",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  child: Text(
                    'Set login pin for easy access in future!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                state is LogInErrorState
                    ? Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      )
                    : const SizedBox(),
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
                  autofocus: true,
                  enableInteractiveSelection: false,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  showCursor: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.w),
                        borderSide: const BorderSide(color: Colors.white)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.w),
                        borderSide: const BorderSide(color: Colors.white54)),
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
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  showCursor: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.w),
                        borderSide: const BorderSide(color: Colors.white)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7.w),
                        borderSide: const BorderSide(color: Colors.white54)),
                    counterText: '',
                  ),
                ),
                SizedBox(height: 20.h),
                BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginedSuccesfullState) {
                      context.go(AppPaths.tabbar);
                    }
                  },
                  child: MaterialButton(
                      minWidth: double.maxFinite,
                      color: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.w)),
                      onPressed: () {
                        bloc.add(SetPinEvent(
                            pinController.text, confirmPinController.text));
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w400),
                      )),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
