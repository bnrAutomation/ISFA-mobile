import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/change_email_phone_module/changeEmailPhone/change_email_phone_bloc.dart';
import 'package:i_densfa/module/change_email_phone_module/change_email_phone_repository.dart';
import 'package:i_densfa/module/login_module/models/login_model.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

class ChangeEmailPhoneView extends StatefulWidget {
  final bool changeEmail;
  const ChangeEmailPhoneView({super.key, required this.changeEmail});

  @override
  State<ChangeEmailPhoneView> createState() => _ChangeEmailPhoneViewState();
}

class _ChangeEmailPhoneViewState extends State<ChangeEmailPhoneView> {
  final emailTextController = TextEditingController();

  final phoneTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String note = widget.changeEmail
        ? "Your new email must be different from your previous email."
        : "Your new phone number must be different from your previous phone number.";
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.changeEmail ? "Change Email" : "Change Phone number",
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
                    if (state is ChangeEmailPhoneErrorState)
                      Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 10),
                    if (widget.changeEmail)
                      TextField(
                        controller: emailTextController,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(" ")
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(74, 158, 158, 158),
                          hintText: "Enter Email",
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    else
                      TextField(
                        controller: phoneTextController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(" "),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(74, 158, 158, 158),
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
                            onPressed: () => widget.changeEmail
                                ? _changeEmail(context)
                                : _changePhone(context),
                            buttonText: widget.changeEmail
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

  void _changeEmail(BuildContext context) async {
    final email = emailTextController.text;
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (email.trim().isEmpty) {
      context.showSnackBarMessage("Please enter email");
    } else if (!emailValid) {
      context.showSnackBarMessage("Please enter a valid email address");
    } else {
      final response = await updateProfile(email: email).catchError((onError) {
        context.showSnackBarMessage(onError.toString());
        throw onError;
      });
      if (response.logindata.userInfo.roles == "user") {
        AppStorage().userDetail = response.logindata.userInfo;
        if (context.mounted) {
          context.showSnackBarMessage('Success');
          Navigator.of(context).pop();
        }
      } else if (context.mounted) {
        context.showSnackBarMessage("User doesn't exist.");
      }
    }
  }

  void _changePhone(BuildContext context) async {
    final phone = phoneTextController.text;
    if (phone.trim().isEmpty) {
      context.showSnackBarMessage("Please enter number");
    } else if (double.tryParse(phone) == null) {
      context.showSnackBarMessage("Please enter valid number");
    } else if (phone.length != 10) {
      context.showSnackBarMessage("Please enter valid number");
    } else {
      final response = await updateProfile(phone: phone).catchError((onError) {
        context.showSnackBarMessage(onError.toString());
        throw onError;
      });
      if (response.logindata.userInfo.roles == "user") {
        AppStorage().userDetail = response.logindata.userInfo;
        if (context.mounted) {
          context.showSnackBarMessage('Success');
          Navigator.of(context).pop();
        }
      } else if (context.mounted) {
        context.showSnackBarMessage("User doesn't exist.");
      }
    }
  }

  Future<LoginModel> updateProfile({String? phone, String? email}) async {
    Map<String, String> bodyMap = {
      if (email != null) "email": email,
      if (phone != null) "mobile": phone
    };
    final response = await put(
      Uri.parse('${URLConstants.updateProfile}/${AppStorage().userDetail!.id}'),
      body: jsonEncode(bodyMap),
      headers: {'Content-Type': 'application/json'},
    );

    final jsonBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return LoginModel.fromRawJson(response.body);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonBody['message'] ?? "Something went wrong";
    }
  }
}
