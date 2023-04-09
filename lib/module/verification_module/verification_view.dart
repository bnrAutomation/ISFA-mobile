import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/ui/background.dart';
import 'package:i_densfa/module/verification_module/verification/verification_bloc.dart';
import 'package:i_densfa/module/verification_module/verification_repository.dart';
import 'package:i_densfa/routes.dart';

class VerificationView extends StatelessWidget {
  final String email;
  final String msg;
  const VerificationView({super.key, required this.email, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          children: [
            const Background(true),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: RepositoryProvider(
                  create: (context) => VerificationRepository(),
                  child: BlocProvider(
                    create: (context) => VerificationBloc(context.read())
                      ..add(VerificationErrorEvent(msg)),
                    child: BlocBuilder<VerificationBloc, VerificationState>(
                      builder: (context, state) {
                        var bloc = context.read<VerificationBloc>();
                        return Column(
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
                                  "Pease enter the 4 digits code sent\nto your registed E-Mail.",
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
                                numberOfFields: 4,
                                borderColor: const Color(0xFF6A53A1),
                                focusedBorderColor: const Color(0xFF6A53A1),
                                enabledBorderColor: const Color(0xFF6A53A1),
                                styles: [
                                  Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          color: const Color(0xFF6A53A1)),
                                  Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          color: const Color(0xFF121212)),
                                  Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          color: const Color(0xFFF99BBD)),
                                  Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          color: const Color(0xFF115C49)),
                                ],
                                showFieldAsBox: false,
                                onCodeChanged: (String code) {
                                  bloc.add(
                                      VerificationTextChangeEvent(code, email));
                                },
                                //runs when every textfield is filled
                                onSubmit: (String verificationCode) {
                                  bloc.add(VerificationTextChangeEvent(
                                      verificationCode, email));
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
                                    onTap: () =>
                                        {bloc.add(ReSendPasswordEvent())},
                                    child: Text(
                                      "Resend OTP",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: BlocConsumer<VerificationBloc,
                                    VerificationState>(
                                  listener: (context, state) {
                                    if (state is VerificationSuccesfullState) {
                                      context.pushNamed(AppPaths.resetPass,
                                          params: {
                                            'email': state.email,
                                            'otp': state.otp
                                          });
                                      // context.pushNamed(AppPaths.resetPass);
                                    }
                                  },
                                  builder: (context, state) {
                                    return SizedBox(
                                      width: 1.sw,
                                      child: Padding(
                                        padding: const EdgeInsets.all(30),
                                        child: MaterialButton(
                                          onPressed: () {
                                            bloc.add(VerificationSubmitEvent(
                                                bloc.varificationCode, email));
                                          },
                                          elevation: 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          splashColor:
                                              Colors.red.withOpacity(0.5),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 25),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(32.0),
                                          ),
                                          child: Text(
                                            state is VerificationLoadingState
                                                ? "Loading.."
                                                : "Verify OTP",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ]);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
