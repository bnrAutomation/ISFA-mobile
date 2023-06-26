import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/forgot_password_module/forget_password_repository.dart';
import 'package:i_densfa/module/forgot_password_module/forgotpassword/forgot_password_bloc.dart';
import 'package:i_densfa/module/ui/background.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/extensions.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final TextEditingController usernameController = TextEditingController();

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
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1.0, // soften the shadow
                      spreadRadius: 1.0, //extend the shadow
                      offset: Offset(
                        1.0, // Move to right 5  horizontally
                        1.0, // Move to bottom 5 Vertically
                      ))
                ],
              ),
              width: 0.9.sw >= 0.9.sh ? 0.9.sh : 0.9.sw,
              // height: 0.7.sw >= 0.7.sh ? 0.7.sh:0.7.sw,
              padding: const EdgeInsets.all(6),
              child: RepositoryProvider(
                create: (context) => ForgotPasswordRepository(),
                child: BlocProvider(
                  create: (context) => ForgotPasswordBloc(context.read()),
                  child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                    builder: (context, state) {
                      var bloc = context.read<ForgotPasswordBloc>();
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Image.asset(
                            ImageConstants.logo,
                            width: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                            //  height: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Please enter your registered email ID to receive Verification code",
                              textAlign: TextAlign.center,
                              style: TextStyle(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          state is ForgotPasswordErrorState
                              ? Text(
                                  state.errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 10),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(" ")
                            ],
                            controller: usernameController,
                            onChanged: (value) => bloc
                                .add(ChangeTextEvent(usernameController.text)),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(74, 158, 158, 158),
                              hintText: "Email Id",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
                            listener: (context, state) {
                              if (state is ForgotPasswordSuccesfullState) {
                                context.showSnackBarMessage(state.message);
                                context.pushReplacementNamed(
                                    AppPaths.passVerification,
                                    pathParameters: {
                                      'email': state.email,
                                      'msg': state.message
                                    });
                              }
                            },
                            builder: (context, state) {
                              return SizedBox(
                                width: 1.sw,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: CustomMaterialButton(
                                      onPressed: () {
                                        if (state
                                            is! ForgotPasswordLoadingState) {
                                          context.hideKeyboard();
                                          bloc.add(ForgotPasswordSubmitEvent(
                                              usernameController.text));
                                        }
                                      },
                                      buttonText:
                                          state is ForgotPasswordLoadingState
                                              ? "Loading..."
                                              : "Get OTP",
                                    )),
                              );
                            },
                          ),
                          const SizedBox(height: 10)
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
