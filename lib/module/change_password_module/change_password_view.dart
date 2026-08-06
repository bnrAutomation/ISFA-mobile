import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/change_password_module/changePassword/change_password_bloc.dart';
import 'package:i_densfa/module/change_password_module/change_password_repository.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/module/ui/dialog_helper.dart';
import 'package:i_densfa/routes.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: RepositoryProvider(
        create: (context) => ChangePasswordRepository(),
        child: BlocProvider(
          create: (context) => ChangePasswordBloc(context.read()),
          child: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
            listener: (context, state) {
              if (state is ChangePasswordSuccesfullState) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Password changed successfully.")));
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go(AppPaths.tabbar);
                }
              } 
              if (state is ChangePasswordErrorState) {
                DialogHelper.showErrorMessage(context, "Alert", state.errorMessage);
              }
            },
            builder: (context, state) {
              var bloc = context.read<ChangePasswordBloc>();

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: const Icon(
                                    Icons.lock_reset_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Change your password",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Your new password must be different from your previous password.",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Current password",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(" ")
                              ],
                              controller: TextEditingController(
                                  text: bloc.oldPassword),
                              obscureText: bloc.isShowingOldPassword,
                              onChanged: (value) {
                                bloc.oldPassword = value;
                              },
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () =>
                                      bloc.add(OldPasswordButtonEvent()),
                                  child: Icon(
                                    bloc.isShowingOldPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                ),
                                hintText: "Enter current password",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "New password",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(" ")
                              ],
                              controller: TextEditingController(
                                  text: bloc.newPassword),
                              obscureText: bloc.isShowingNewPassword,
                              onChanged: (value) {
                                bloc.newPassword = value;
                              },
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () =>
                                      bloc.add(NewPasswordButtonEvent()),
                                  child: Icon(
                                    bloc.isShowingNewPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                ),
                                hintText: "Create a new password",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: CustomButton(
                                  onPressed: () {
                                    if (state
                                        is! ChangePasswordLoadingState) {
                                      bloc.add(SubmitChangePasswordEvent(
                                        bloc.newPassword,
                                        bloc.oldPassword,
                                      ));
                                    }
                                  },
                                  buttonText: "Change Password",
                                  isLoading:
                                      state is ChangePasswordLoadingState,
                                  isSuccess:
                                      state is ChangePasswordSuccesfullState,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
