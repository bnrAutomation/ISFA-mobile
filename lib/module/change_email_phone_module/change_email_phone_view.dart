import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/login_module/models/auth_model.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/change_email_phone_module/changeEmailPhone/change_email_phone_bloc.dart';
import 'package:i_densfa/module/change_email_phone_module/change_email_phone_repository.dart';
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
    //  backgroundColor: Theme.of(context).colorScheme.primary,//.withValues(alpha:0.5),
      appBar: AppBar(
       // backgroundColor: Theme.of(context).colorScheme.primary,
        title:
            Text(widget.changeEmail ? "Change Email" : "Change Phone number"),
      ),
      body: RepositoryProvider(
        create: (context) => ChangeEmailPhoneRepository(),
        child: BlocProvider(
          create: (context) => ChangeEmailPhoneBloc(),
          child: BlocBuilder<ChangeEmailPhoneBloc, ChangeEmailPhoneState>(
            builder: (context, state) {
              final user = AppStorage().userDetail;
              final currentValue = widget.changeEmail
                  ? (user?.email ?? "-")
                  : (user?.mobile ?? "-");
              final title =
                  widget.changeEmail ? "Update your email" : "Update your phone";
              final fieldLabel =
                  widget.changeEmail ? "New email address" : "New phone number";

              return SafeArea(
                child:  SingleChildScrollView(
                
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      elevation: 0,
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
                                  child: Icon(
                                    widget.changeEmail
                                        ? Icons.email_outlined
                                        : Icons.phone_iphone_outlined,
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
                                        title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        note,
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
                            const SizedBox(height: 16),
                            Text(
                              widget.changeEmail
                                  ? "Current email"
                                  : "Current phone",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentValue,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              fieldLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            if (widget.changeEmail)
                              TextField(
                                controller: emailTextController,
                                keyboardType: TextInputType.emailAddress,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(" ")
                                ],
                                decoration: InputDecoration(
                                  hintText: "name@example.com",
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
                                        color:
                                            Theme.of(context).primaryColor),
                                  ),
                                ),
                              )
                            else
                              TextField(
                                controller: phoneTextController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(" "),
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                decoration: InputDecoration(
                                  hintText: "10-digit mobile number",
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
                                        color:
                                            Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            if (state is ChangeEmailPhoneErrorState) ...[
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: CustomMaterialButton(
                                onPressed: () => widget.changeEmail
                                    ? _changeEmail(context)
                                    : _changePhone(context),
                                buttonText: widget.changeEmail
                                    ? "Change email"
                                    : "Change phone number",
                              ),
                            )
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
      final response = await _updateProfile(email: email).catchError((onError) {
        if (context.mounted) {
          context.showSnackBarMessage(onError.toString());
        }
        throw onError;
      });
      if (response.role != "admin") {
        AppStorage().userDetail = response;
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
      final response = await _updateProfile(phone: phone).catchError((onError) {
        if (context.mounted) {
          context.showSnackBarMessage(onError.toString());
        }
        throw onError;
      });
      if (response.role != "admin") {
        AppStorage().userDetail = response;
        if (context.mounted) {
          context.showSnackBarMessage('Success');
          Navigator.of(context).pop();
        }
      } else if (context.mounted) {
        context.showSnackBarMessage("User doesn't exist.");
      }
    }
  }

  Future<UserInfo> _updateProfile({String? phone, String? email}) async {
    final userId = AppStorage().userDetail!.id;
    Map<String, String> bodyMap = {
      if (email != null) "email": email,
      if (phone != null) "mobile": phone
    };
    final response = await CustomHttpBaseClient.instance.put(
      Uri.parse('${URLConstants.updateProfile}/$userId'),
      body: jsonEncode(bodyMap),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final info = await _getUserDetails(userId);
      return info;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<UserInfo> _getUserDetails(userID) async {
    final response = await CustomHttpBaseClient.instance
        .get(Uri.parse('${URLConstants.userDetails}/$userID'));
    if (response.statusCode == 200) {
      return UserDetailsResponseModel.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }
}
