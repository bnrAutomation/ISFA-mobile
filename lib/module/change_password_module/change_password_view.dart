import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/change_password_module/changePassword/change_password_bloc.dart';
import 'package:i_densfa/module/change_password_module/change_password_repository.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';

class ChangePasswordView extends StatelessWidget {
  ChangePasswordView({super.key});
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Change Password",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: RepositoryProvider(
        create: (context) => ChangePasswordRepository(),
        child: BlocProvider(
          create: (context) => ChangePasswordBloc(context.read()),
          child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
            builder: (context, state) {
              var bloc = context.read<ChangePasswordBloc>();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "NOTE : Your new password must be different from your previous password.",
                        textAlign: TextAlign.center,
                        style: TextStyle(),
                      ),
                      state is ChangePasswordErrorState
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
                        controller: oldPasswordController,
                        obscureText: bloc.isShowingOldPassword,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: () => bloc.add(OldPasswordButtonEvent()),
                            child: Container(
                              color: Colors.transparent,
                              child: Icon(
                                bloc.isShowingOldPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(74, 158, 158, 158),
                          hintText: "Old Password",
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(" ")
                        ],
                        controller: newPasswordController,
                        obscureText: bloc.isShowingNewPassword,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: () => bloc.add(NewPasswordButtonEvent()),
                            child: Container(
                              color: Colors.transparent,
                              child: Icon(
                                bloc.isShowingNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
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
                      const SizedBox(height: 10),
                      BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
                        listener: (context, state) {
                          if (state is ChangePasswordSuccesfullState) {
                            Navigator.pop(context);
                          }
                        },
                        builder: (context, state) {
                          return SizedBox(
                            width: 1.sw,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: CustomMaterialButton(
                                  onPressed: () {
                                    if (state is! ChangePasswordLoadingState) {
                                      bloc.add(SubmitChangePasswordEvent(
                                        newPasswordController.text,
                                        oldPasswordController.text,
                                      ));
                                    }
                                  },
                                  buttonText:
                                      state is ChangePasswordLoadingState
                                          ? "Loading..."
                                          : "Change Passsord",
                                )),
                          );
                        },
                      ),
                      const SizedBox(height: 10)
                    ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
