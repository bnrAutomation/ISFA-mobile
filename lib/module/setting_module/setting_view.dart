import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:upgrader/upgrader.dart';

import '../ui/app_image_picker.dart';
import 'bloc/settings_bloc.dart';

class SettingView extends StatelessWidget {
  final String name;
  const SettingView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: Scaffold(
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
                            child: CustomAnimationBuilder(
                          duration: const Duration(seconds: 1),
                          tween: Tween<double>(begin: 0, end: 250),
                          builder: (context, animation, child) {
                            return Container(
                              height: animation,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(25.0),
                                      bottomLeft: Radius.circular(25.0)),
                                  color: Theme.of(context).primaryColor),
                            );
                          },
                        )),
                        Positioned.fill(
                            child: CustomAnimationBuilder(
                                duration: const Duration(seconds: 1),
                                delay:
                                    Duration(milliseconds: (500 * 2).round()),
                                curve: Curves.elasticOut,
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (BuildContext context, value,
                                    Widget? child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 100),
                                        InkWell(
                                          onTap: () {
                                            AppImagePicker(context,
                                                (imageFile) {
                                              bloc.add(ChangeImageSettingsEvent(
                                                  imageFile));
                                            });
                                          },
                                          child: Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 55.0,
                                                backgroundColor: Colors.grey
                                                    .withValues(alpha: 0.2),
                                                child: state
                                                        is ImageLoadingState
                                                    ? const CircularProgressIndicator(
                                                        color: ColorConstants
                                                            .amber)
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(110),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: userdetails
                                                              .photoUrl,
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              CachedNetworkImage(
                                                                  imageUrl:
                                                                      ImageConstants
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
                                                    decoration:
                                                        const BoxDecoration(
                                                      color:
                                                          ColorConstants.amber,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                        Icons.edit_outlined),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "${userdetails.fullName}(${userdetails.role})",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(25.0),
                                              ),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          child: Text(
                                            AppStorage()
                                                    .homeInfo
                                                    ?.userInfo
                                                    .companyName ??
                                                "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                    fontSize: 14.sp,
                                                    //color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }))
                      ],
                    ),
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: AnimationLimiter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
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
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                              SettingListTile(
                                leadingIcon: Icons.info_outline,
                                title: 'Info',
                                subTitle: 'Click to check account info',
                                tail: true,
                                onTap: () =>
                                    context.pushNamed(AppPaths.profileInfo),
                              ),
                              SettingListTile(
                                leadingIcon: Icons.email_outlined,
                                title: "Email",
                                subTitle: userdetails.email,
                                tail: userdetails
                                    .configuration.requiredEmailChange,
                                onTap: userdetails
                                        .configuration.requiredEmailChange
                                    ? () async {
                                        await context.pushNamed(
                                            AppPaths.changeEmailPhone,
                                            pathParameters: {
                                              'changeEmail': "true"
                                            });
                                        bloc.add(
                                            ChangeEmailPhoneSettingsEvent());
                                      }
                                    : null,
                              ),
                              SettingListTile(
                                leadingIcon: Icons.call_outlined,
                                title: "Phone Number",
                                subTitle: userdetails.mobile,
                                tail: userdetails
                                    .configuration.requiredPhoneChange,
                                onTap: userdetails
                                        .configuration.requiredPhoneChange
                                    ? () async {
                                        await context.pushNamed(
                                            AppPaths.changeEmailPhone,
                                            pathParameters: {
                                              'changeEmail': "false"
                                            });
                                        bloc.add(
                                            ChangeEmailPhoneSettingsEvent());
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: AnimationLimiter(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 375),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: widget,
                                    ),
                                  ),
                              children: [
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
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
                                  tail: userdetails
                                      .configuration.requiredPasswordChange,
                                  onTap: userdetails
                                          .configuration.requiredPasswordChange
                                      ? () =>
                                          context.pushNamed(AppPaths.changePass)
                                      : null,
                                ),
                                SettingListTile(
                                  leadingIcon: Icons.pin_outlined,
                                  title: "Change PIN",
                                  subTitle: "Click to change PIN",
                                  tail: true,
                                  onTap: () =>
                                      context.pushNamed(AppPaths.pinset),
                                ),
                                SettingListTile(
                                  leadingIcon: Icons.policy_outlined,
                                  title: "Policy",
                                  subTitle: "Click to check policy",
                                  tail: true,
                                  onTap: () =>
                                      context.pushNamed(AppPaths.policy),
                                ),
                                SettingListTile(
                                  leadingIcon: Icons.info_outline,
                                  title: "About Us",
                                  subTitle: "Click to know about us",
                                  tail: true,
                                  onTap: () =>
                                      context.pushNamed(AppPaths.aboutUs),
                                ),
                              ])),
                    ),
                  ),
                  const SizedBox(height: 100)
                ]))
              ],
            );
          },
        ),
      )),
    );
  }
}

class SettingListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData leadingIcon;
  final void Function()? onTap;
  final bool tail;

  const SettingListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subTitle,
    required this.tail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(
          leadingIcon,
          size: 24,
          color: Colors.black,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        subtitle: Text(
          subTitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: tail
            ? const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey)
            : null,
      ),
    );
  }
}
