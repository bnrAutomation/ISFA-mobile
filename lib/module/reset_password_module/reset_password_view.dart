import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/login_module/login_view.dart';
import 'package:i_densfa/module/reset_password_module/reset_password/reset_password_bloc.dart';
import 'package:i_densfa/module/ui/background.dart';
import 'package:i_densfa/utility/image_constants.dart';

class ResetPasswordView extends StatelessWidget {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasssordController =
      TextEditingController();

  ResetPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocProvider(
        create: (context) => ResetPasswordBloc(),
        child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
          builder: (context, state) {
            return Stack(
              children: [
                const Background(true),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0)),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Image.asset(
                          imageConstants.logo,
                          width: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                          // height: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Your new password must be diffrent from your previously userd password",
                            textAlign: TextAlign.center,
                            style: TextStyle(),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        state is ResetPasswordErrorState
                            ? Text(
                                state.errorMessage,
                                style: const TextStyle(color: Colors.red),
                              )
                            : Container(),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: newPasswordController,
                          onChanged: (value) => {
                            BlocProvider.of<ResetPasswordBloc>(context).add(
                                ChangePassword(newPasswordController.text,
                                    confirmPasssordController.text))
                          },
                          obscureText: context
                              .read<ResetPasswordBloc>()
                              .isShowingNewPassword,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () => {
                                BlocProvider.of<ResetPasswordBloc>(context)
                                    .add(NewPasswordButtonEvent())
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Icon(
                                  state is ShowNewPasswordState
                                      ? state.visible
                                          ? Icons.visibility
                                          : Icons.visibility_off
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(74, 158, 158, 158),
                            hintText: "New Password",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: confirmPasssordController,
                          onChanged: (value) => {
                            BlocProvider.of<ResetPasswordBloc>(context).add(
                                ChangePassword(newPasswordController.text,
                                    confirmPasssordController.text))
                          },
                          obscureText: context
                              .read<ResetPasswordBloc>()
                              .isShowingConfirmPassword,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () => {
                                BlocProvider.of<ResetPasswordBloc>(context)
                                    .add(ConfirmPasswordButtonEvent())
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Icon(
                                  state is ShowConfirmPasswordState
                                      ? state.visible
                                          ? Icons.visibility
                                          : Icons.visibility_off
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(74, 158, 158, 158),
                            hintText: "Confirm Password",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        const SizedBox(
                          height: 10,
                        ),
                        BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
                          listener: (context, state) {
                            if (state is ResetPasswordSuccesfullState) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => LoginView())),
                                  (route) => false);
                            }
                          },
                          builder: (context, state) {
                            return SizedBox(
                              width: 1.sw,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: MaterialButton(
                                  onPressed: () => {
                                    BlocProvider.of<ResetPasswordBloc>(context)
                                        .add(SubmitChangePasswordEvent(
                                            newPasswordController.text,
                                            confirmPasssordController.text))
                                  },
                                  elevation: 2,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  splashColor: Colors.red.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 25),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                  ),
                                  child: const Text(
                                    "Change Passsord",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
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
