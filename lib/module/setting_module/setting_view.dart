import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../ui/app_image_picker.dart';
import 'bloc/settings_bloc.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final userdetails = AppStorage().userDetail!;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: BlocProvider(
          create: (context) => SettingsBloc(),
          child: BlocConsumer<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is SnackBarMessageSettingsState) {
                context.showSnackBarMessage(state.message);
              }
            },
            builder: (context, state) {
              var bloc = context.read<SettingsBloc>();
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    iconTheme: const IconThemeData(color: Colors.white),
                    backgroundColor: const Color(0XFFBFD1DF),
                    expandedHeight: 380,
                    floating: true,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          Positioned(
                              child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(25.0),
                                    bottomLeft: Radius.circular(25.0)),
                                color: Theme.of(context).colorScheme.primary),
                          )),
                          Positioned.fill(
                              child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 100),
                                InkWell(
                                  onTap: () {
                                    AppImagePicker(context, (imageFile) {
                                      bloc.add(
                                          ChangeImageSettingsEvent(imageFile));
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 55.0,
                                        backgroundImage:
                                            NetworkImage(bloc.userImageLink),
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.2),
                                      ),
                                      Positioned(
                                          bottom: 1,
                                          right: 1,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: Colors.amber,
                                              shape: BoxShape.circle,
                                            ),
                                            child:
                                                const Icon(Icons.edit_outlined),
                                          ))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${userdetails.username}(${userdetails.designation})",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(25.0),
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                  child: Text(
                                    'Company : ${userdetails.companyName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontSize: 14.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                  ),
                                )
                              ],
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Account Infomation',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          InkWell(
                            onTap: () => {
                              context.pushNamed(AppPaths.changeEmailPhone,
                                  pathParameters: {
                                    'changeEmail': "true",
                                  })
                            },
                            child: ListTile(
                              leading: const Icon(
                                Icons.email_outlined,
                                size: 28,
                                color: Colors.black,
                              ),
                              title: Text(
                                "Email",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                              ),
                              subtitle: Text(
                                userdetails.email,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 18, color: Colors.grey),
                            ),
                          ),
                          InkWell(
                            onTap: () => {
                              context.pushNamed(AppPaths.changeEmailPhone,
                                  pathParameters: {
                                    'changeEmail': "false",
                                  })
                            },
                            child: ListTile(
                              leading: const Icon(
                                Icons.call_outlined,
                                size: 28,
                                color: Colors.black,
                              ),
                              title: Text(
                                "Phone Number",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                              ),
                              subtitle: Text(
                                userdetails.mobile,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 18, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'General Setting',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Colors.grey,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.pushNamed(AppPaths.changePass);
                              },
                              child: ListTile(
                                leading: const Icon(
                                  Icons.lock_outline,
                                  size: 28,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  "Change Password",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                ),
                                subtitle: Text(
                                  "Click to change Password",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: Colors.grey),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.pushNamed(AppPaths.pinset);
                              },
                              child: ListTile(
                                leading: const Icon(
                                  Icons.pin_outlined,
                                  size: 28,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  "Change PIN",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                ),
                                subtitle: Text(
                                  "Click to change PIN",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: Colors.grey),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.pushNamed(AppPaths.policy);
                              },
                              child: ListTile(
                                leading: const Icon(
                                  Icons.policy_outlined,
                                  size: 28,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  "Policy",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                ),
                                subtitle: Text(
                                  "Click to check policy",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: Colors.grey),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.pushNamed(AppPaths.aboutUs);
                              },
                              child: ListTile(
                                leading: const Icon(
                                  Icons.info_outline,
                                  size: 28,
                                  color: Colors.black,
                                ),
                                title: Text(
                                  "About Us",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                ),
                                subtitle: Text(
                                  "Click to know about us",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: Colors.grey),
                              ),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 100)
                  ]))
                ],
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
