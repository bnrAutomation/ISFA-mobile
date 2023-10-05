import 'package:flutter/material.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/ui/background.dart';
import 'package:i_densfa/module/verification_module/verification/verification_bloc.dart';
import 'package:i_densfa/module/verification_module/verification_repository.dart';
import 'package:i_densfa/routes.dart';
import 'package:otp_text_field/style.dart';

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
                                  "Please enter the 4 digits code sent\nto your registered E-Mail.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
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
                                  : const SizedBox(),
                              const SizedBox(height: 10),
                              const SizedBox(height: 10),
                              OTPTextField(
                                length: 4,
                                width: MediaQuery.of(context).size.width,
                                textFieldAlignment:
                                    MainAxisAlignment.spaceAround,
                                fieldWidth: 45,
                                fieldStyle: FieldStyle.underline,
                                otpFieldStyle: OtpFieldStyle(
                                    enabledBorderColor: Colors.amber,
                                    focusBorderColor: Colors.amber,
                                    borderColor: Colors.white),
                                outlineBorderRadius: 15,
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.white),
                                onChanged: (String code) {
                                  bloc.add(
                                      VerificationTextChangeEvent(code, email));
                                },
                                //runs when every textfield is filled
                                onCompleted: (String verificationCode) {
                                  bloc.add(VerificationTextChangeEvent(
                                      verificationCode, email));
                                },
                              ),
                              const SizedBox(height: 20),
                              BlocConsumer<VerificationBloc, VerificationState>(
                                listener: (context, state) {
                                  if (state is VerificationCodeResend) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      backgroundColor: ColorConstants.amber,
                                      content: Text(
                                        'Your Verification code has re-sent your registerd e-mail.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      duration: Duration(seconds: 2),
                                    ));
                                  }
                                },
                                builder: (context, state) {
                                  return InkWell(
                                    onTap: () =>
                                        {bloc.add(ReSendPasswordEvent(email))},
                                    child: Text(
                                      state is ReSendLoadingState
                                          ? "Loading..."
                                          : "Resend OTP",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: BlocConsumer<VerificationBloc,
                                    VerificationState>(
                                  listener: (context, state) {
                                    if (state is VerificationSuccesfullState) {
                                      context.pushReplacementNamed(
                                          AppPaths.resetPass,
                                          pathParameters: {
                                            'email': state.email,
                                            'otp': state.otp
                                          });
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
                                              .primary,
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
                                                color: Colors.black),
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
