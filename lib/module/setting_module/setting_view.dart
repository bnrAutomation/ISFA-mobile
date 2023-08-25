import 'package:cached_network_image/cached_network_image.dart';
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
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.2),
                                      child: state is ImageLoadingState
                                          ? const CircularProgressIndicator(
                                              color: ColorConstants.amber)
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(110),
                                              child: CachedNetworkImage(
                                                imageUrl: userdetails.photoUrl,
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url,
                                                        error) =>
                                                    CachedNetworkImage(
                                                        imageUrl: ImageConstants
                                                            .placeholderUserUrl),
                                              ),
                                            ),
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
                    Padding(
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
                          SettingListTile(
                            leadingIcon: Icons.info_outline,
                            title: 'Info',
                            subTitle: 'Click to check account info',
                            onTap: () =>
                                context.pushNamed(AppPaths.profileInfo),
                          ),
                          SettingListTile(
                            leadingIcon: Icons.email_outlined,
                            title: "Email",
                            subTitle: userdetails.email,
                            onTap: () async {
                              await context.pushNamed(AppPaths.changeEmailPhone,
                                  pathParameters: {'changeEmail': "true"});
                              bloc.add(ChangeEmailPhoneSettingsEvent());
                            },
                          ),
                          SettingListTile(
                            leadingIcon: Icons.call_outlined,
                            title: "Phone Number",
                            subTitle: userdetails.mobile,
                            onTap: () async {
                              await context.pushNamed(AppPaths.changeEmailPhone,
                                  pathParameters: {'changeEmail': "false"});
                              bloc.add(ChangeEmailPhoneSettingsEvent());
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
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
                            SettingListTile(
                              leadingIcon: Icons.lock_outline,
                              title: "Change Password",
                              subTitle: "Click to change Password",
                              onTap: () =>
                                  context.pushNamed(AppPaths.changePass),
                            ),
                            SettingListTile(
                              leadingIcon: Icons.pin_outlined,
                              title: "Change PIN",
                              subTitle: "Click to change PIN",
                              onTap: () => context.pushNamed(AppPaths.pinset),
                            ),
                            SettingListTile(
                              leadingIcon: Icons.policy_outlined,
                              title: "Policy",
                              subTitle: "Click to check policy",
                              onTap: () => context.pushNamed(AppPaths.policy),
                            ),
                            SettingListTile(
                              leadingIcon: Icons.info_outline,
                              title: "About Us",
                              subTitle: "Click to know about us",
                              onTap: () => context.pushNamed(AppPaths.aboutUs),
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

class SettingListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData leadingIcon;
  final void Function()? onTap;

  const SettingListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(
          leadingIcon,
          size: 28,
          color: Colors.black,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary),
        ),
        subtitle: Text(
          subTitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      ),
    );
  }
}
