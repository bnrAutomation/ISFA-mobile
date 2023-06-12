import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/change_email_phone_module/changeEmailPhone/change_email_phone_bloc.dart';
import 'package:i_densfa/module/change_email_phone_module/change_email_phone_repository.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';

class ChangeEmailPhoneView extends StatelessWidget {
  final bool changeEmail;
  const ChangeEmailPhoneView({super.key, required this.changeEmail});
  @override
  Widget build(BuildContext context) {
    String note = changeEmail
        ? "Your new email must be different from your previous email."
        : "Your new phone number must be different from your previous phone number.";
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          changeEmail ? "Change Email" : "Change Phone number",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RepositoryProvider(
          create: (context) => ChangeEmailPhoneRepository(),
          child: BlocProvider(
            create: (context) => ChangeEmailPhoneBloc(),
            child: BlocBuilder<ChangeEmailPhoneBloc, ChangeEmailPhoneState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "NOTE : $note",
                      textAlign: TextAlign.center,
                    ),
                    state is ChangeEmailPhoneErrorState
                        ? Text(
                            state.errorMessage,
                            style: const TextStyle(color: Colors.red),
                          )
                        : const SizedBox(),
                    const SizedBox(height: 10),
                    changeEmail
                        ? TextField(
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(" ")
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(74, 158, 158, 158),
                              hintText: "Enter Email",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          )
                        : const SizedBox(),
                    changeEmail
                        ? const SizedBox()
                        : TextField(
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(" ")
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(74, 158, 158, 158),
                              hintText: "Enter Phone number",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 1.sw,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CustomMaterialButton(
                            onPressed: () {},
                            buttonText: changeEmail
                                ? "Change email"
                                : "Change phone number",
                          )),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
