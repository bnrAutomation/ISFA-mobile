import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/ui/background.dart';
import 'package:i_densfa/module/verification_module/verification/verification_bloc.dart';

import '../reset_password_module/reset_password_view.dart';

class VerificationView extends StatelessWidget {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocProvider(
        create: (context) => VerificationBloc(),
        child: BlocBuilder<VerificationBloc, VerificationState>(
          builder: (context, state) {
            return Stack(
              children: [
                const Background(true),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    // width: 0.9.sw >= 0.9.sh ? 0.9.sh : 0.9.sw,
                    // height: 0.7.sw >= 0.7.sh ? 0.7.sh:0.7.sw,
                    padding: const EdgeInsets.all(6),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Pease enter the 6 digits code sent\nto your registed E-Mail.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          state is VerificationErrorState
                              ? Text(
                                  state.errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          OtpTextField(
                            numberOfFields: 6,
                            borderColor: const Color(0xFF6A53A1),
                            focusedBorderColor: const Color(0xFF6A53A1),
                            enabledBorderColor: const Color(0xFF6A53A1),
                            styles: [
                              Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: const Color(0xFF6A53A1)),
                              Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: const Color(0xFF121212)),
                              Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: const Color(0xFFF99BBD)),
                              Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: const Color(0xFF115C49)),
                              Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: const Color(0xFFFFB612)),
                              Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: const Color(0xFFEA7A3B)),
                            ],
                            showFieldAsBox: false,

                            // borderWidth: 3.0,
                            //runs when a code is typed in
                            onCodeChanged: (String code) {
                              BlocProvider.of<VerificationBloc>(context)
                                  .add(VerificationTextChangeEvent(code));
                            },
                            //runs when every textfield is filled
                            onSubmit: (String verificationCode) {
                              BlocProvider.of<VerificationBloc>(context)
                                  .add(VerificationSubmitEvent());
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          BlocConsumer<VerificationBloc, VerificationState>(
                            listener: (context, state) {
                              if (state is VerificationCodeResend) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  backgroundColor: Colors.amber,
                                  content: Text(
                                    'Your Verification code has re-sent your registerd e-mail.',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  duration: Duration(seconds: 2),
                                ));
                              }
                            },
                            builder: (context, state) {
                              return InkWell(
                                onTap: () => {
                                  BlocProvider.of<VerificationBloc>(context)
                                      .add(ReSendPasswordEvent())
                                },
                                child: Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              );
                            },
                          )
                        ]),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BlocConsumer<VerificationBloc, VerificationState>(
                    listener: (context, state) {
                      if (state is VerificationSuccesfullState) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => ResetPasswordView())));
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: 1.sw,
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: MaterialButton(
                            onPressed: () {
                              BlocProvider.of<VerificationBloc>(context)
                                  .add(VerificationSubmitEvent());
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
                              "Verify OTP",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
