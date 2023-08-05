import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../ui/app_image_picker.dart';
import 'bloc/settings_bloc.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
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
              final bloc = context.read<SettingsBloc>();
              final userdetails = AppStorage().userDetail!;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    iconTheme: const IconThemeData(color: Colors.white),
                    backgroundColor: const Color(0XFFBFD1DF),
                    expandedHeight: 380,
                    floating: true,
                    pinned: true,
                    actions: [
                      TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white),
                          onPressed: () =>
                              context.pushNamed(AppPaths.profileInfo),
                          child: const Text('Info'))
                    ],
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
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                      backgroundImage: NetworkImage(
                                          userdetails.photoUrl.contains('http')
                                              ? userdetails.photoUrl
                                              : bloc.dpPlaceholderLink),
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.2),
                                      child: state is ImageLoadingState
                                          ? const CircularProgressIndicator(
                                              color: ColorConstants.amber,
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                        bottom: 1,
                                        right: 1,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: const BoxDecoration(
                                            color: ColorConstants.amber,
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
                            onTap: () async {
                              await context.pushNamed(AppPaths.changeEmailPhone,
                                  pathParameters: {'changeEmail': "true"});
                              bloc.add(ChangeEmailPhoneSettingsEvent());
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
                            onTap: () async {
                              await context.pushNamed(AppPaths.changeEmailPhone,
                                  pathParameters: {'changeEmail': "false"});
                              bloc.add(ChangeEmailPhoneSettingsEvent());
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
