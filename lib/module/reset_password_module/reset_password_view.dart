import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/reset_password_module/reset_password/reset_password_bloc.dart';
import 'package:i_densfa/module/reset_password_module/reset_password_repository.dart';
import 'package:i_densfa/module/ui/background.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';

class ResetPasswordView extends StatelessWidget {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasssordController =
      TextEditingController();

  final String email;
  final String otp;

  ResetPasswordView({super.key, required this.email, required this.otp});
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
                  create: (context) => ResetPasswordRepository(),
                  child: BlocProvider(
                    create: (context) => ResetPasswordBloc(context.read()),
                    child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                      builder: (context, state) {
                        var bloc = context.read<ResetPasswordBloc>();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Image.asset(
                              ImageConstants.logo,
                              width: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                              // height: 0.2.sw >= 0.2.sh ? 0.2.sh : 0.2.sw,
                            ),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Your new password must be different from your previously password",
                                textAlign: TextAlign.center,
                                style: TextStyle(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            state is ResetPasswordErrorState
                                ? Text(
                                    state.errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 10),
                            TextField(
                              controller: newPasswordController,
                              onChanged: (value) => bloc.add(ChangePassword(
                                  newPasswordController.text,
                                  confirmPasssordController.text)),
                              obscureText: context
                                  .read<ResetPasswordBloc>()
                                  .isShowingNewPassword,
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () =>
                                      {bloc.add(NewPasswordButtonEvent())},
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
                                fillColor:
                                    const Color.fromARGB(74, 158, 158, 158),
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
                              onChanged: (value) => bloc.add(ChangePassword(
                                  newPasswordController.text,
                                  confirmPasssordController.text)),
                              obscureText: context
                                  .read<ResetPasswordBloc>()
                                  .isShowingConfirmPassword,
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () =>
                                      {bloc.add(ConfirmPasswordButtonEvent())},
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
                                fillColor:
                                    const Color.fromARGB(74, 158, 158, 158),
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
                                  context.go(AppPaths.login);
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
                                              is! ResetPasswordLoadingState) {
                                            bloc.add(SubmitChangePasswordEvent(
                                                newPasswordController.text,
                                                confirmPasssordController.text,
                                                otp,
                                                email));
                                          }
                                        },
                                        buttonText:
                                            state is ResetPasswordLoadingState
                                                ? "Loading..."
                                                : "Change Passsord",
                                      )),
                                );
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
