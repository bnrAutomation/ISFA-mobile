import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';

import '../ui/app_image_picker.dart';
import 'bloc/settings_bloc.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Settings",
            style: textTheme.titleSmall?.copyWith(color: Colors.white),
          ),
        ),
        body: BlocProvider(
          create: (context) => SettingsBloc(),
          child: BlocConsumer<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is SnackBarMessageSettingsState) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SettingProfileView(bloc: context.read()),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'General',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          context.pushNamed(AppPaths.changePass);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,

                                offset: const Offset(
                                    0, 0.1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: const ListTile(
                            title: Text("Change Password",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontSize: 16)),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.pushNamed(AppPaths.pinset);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,

                                offset: const Offset(
                                    0, 0.1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: const ListTile(
                            title: Text("Change PIN",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontSize: 16)),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          context.pushNamed(AppPaths.policy);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                offset: const Offset(0, 0.1),
                              ),
                            ],
                          ),
                          child: const ListTile(
                            title: Text("Policy",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontSize: 16)),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => context.pushNamed(AppPaths.aboutUs),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                offset: const Offset(0, 0.1),
                              ),
                            ],
                          ),
                          child: const ListTile(
                            title: Text("About Us",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontSize: 16)),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ]),
              );
            },
          ),
        ));
  }
}

class SettingProfileView extends StatelessWidget {
  final SettingsBloc bloc;
  const SettingProfileView({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final userdetails = AppStorage().userDetail!;
    return Container(
        padding: const EdgeInsets.all(10),
        width: 1.sw,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                AppImagePicker(context, (imageFile) {
                  bloc.add(ChangeImageSettingsEvent(imageFile));
                });
              },
              child: CircleAvatar(
                radius: 35.0,
                backgroundImage: NetworkImage(bloc.userImageLink),
                backgroundColor: Colors.grey.withOpacity(0.2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${userdetails.username}(${userdetails.designation})",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.mail,
                              color: Colors.black,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              userdetails.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      TextEditButton(
                        onTap: () => _emailPopUp(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.phone_circle,
                              color: Colors.black,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              userdetails.mobile,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      TextEditButton(
                        onTap: () => _numberPopUp(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        CupertinoIcons.line_horizontal_3_decrease_circle,
                        color: Colors.black,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Company : ${userdetails.companyName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }

  void _emailPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditDialog(
        title: 'Enter email',
        placeHolder: 'Please enter email...',
        keyboardType: TextInputType.emailAddress,
        onSave: (email) => bloc.add(ChangeEmailSettingsEvent(email)),
      ),
    );
  }

  void _numberPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditDialog(
        title: 'Enter Mobile',
        placeHolder: 'Please enter number...',
        keyboardType: TextInputType.phone,
        onSave: (phone) => bloc.add(ChangePhoneSettingsEvent(phone)),
      ),
    );
  }
}

class EditDialog extends StatelessWidget {
  final String title;
  final String placeHolder;
  final void Function(String) onSave;
  final TextInputType? keyboardType;
  final textController = TextEditingController();
  EditDialog({
    super.key,
    required this.title,
    required this.placeHolder,
    required this.onSave,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: CupertinoAlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          keyboardType: keyboardType,
          decoration: InputDecoration(
              hintText: placeHolder, border: const OutlineInputBorder()),
        ),
        actions: [
          CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text("Save"),
              onPressed: () {
                onSave(textController.text);
                Navigator.pop(context);
              }),
          CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ))
        ],
      ),
    );
  }
}

class TextEditButton extends StatelessWidget {
  final void Function() onTap;
  const TextEditButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 20.h,
        child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Text(
                'Edit',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
            )));
  }
}
