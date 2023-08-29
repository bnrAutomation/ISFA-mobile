import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'bloc/tabbar_bloc.dart';
import 'models/side_menu_model.dart';

class AppSideMenu extends StatelessWidget {
  final SideMenuModel data;
  const AppSideMenu({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              currentAccountPicture: CircleAvatar(
                radius: 55.0,
                backgroundColor: Colors.grey.withOpacity(0.2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(110),
                  child: CachedNetworkImage(
                    imageUrl: AppStorage().userDetail!.photoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => CachedNetworkImage(
                        imageUrl: ImageConstants.placeholderUserUrl),
                  ),
                ),
              ),
              otherAccountsPictures: [dutyStatus()],
              accountName:
                  Text("${data.userInfo.userName} (${data.userInfo.iRole})"),
              accountEmail: Text(data.userInfo.companyName)),
          ...data.menu.where((element) => element.isActive).map(
            (e) {
              return ListTile(
                leading: CachedNetworkImage(
                  fit: BoxFit.contain,
                  imageUrl: e.icon,
                  width: 25.w,
                  height: 25.w,
                  errorWidget: (context, url, error) =>
                      const ColoredBox(color: Colors.red),
                ),
                title: Text(e.name),
                onTap: () {
                  switch (e.key.toLowerCase()) {
                    case 'promoter':
                      closeDrawerAndPushView(context, AppPaths.promoter);
                      break;
                    case 'leave':
                      closeDrawerAndPushView(context, AppPaths.leave);
                      break;
                    case 'attendance':
                      closeDrawerAndPushView(context, AppPaths.attendance);
                      break;
                    case 'my activity':
                      closeDrawerAndPushView(context, AppPaths.myActivity);
                      break;
                    case 'assessment':
                      closeDrawerAndPushView(context, AppPaths.assessmentList);
                      break;
                    default:
                      Navigator.pop(context);
                  }
                },
              );
            },
          ).toList(),
          // if (data.userInfo.iRole.toLowerCase() != 'fwp')
          //   ListTile(
          //     leading: const Icon(Icons.group),
          //     title: const Text('Team'),
          //     onTap: () {
          //       closeDrawerAndPushView(context, AppPaths.team);
          //     },
          //   ),
          ListTile(
            leading: const Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 30,
            ),
            title: const Text('Settings'),
            onTap: () {
              closeDrawerAndPushView(context, AppPaths.setting);
              //  Scaffold.of(context).closeDrawer();
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.help_outline),
          //   title: const Text('Help'),
          //   onTap: () {
          //     Scaffold.of(context).closeDrawer();
          //   },
          // ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.black,
              size: 30,
            ),
            title: const Text('Logout'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
              AppStorage().logout();
              context.go(AppPaths.login);
            },
          ),
        ],
      ),
    );
  }

  Widget dutyStatus() {
    return BlocBuilder<TabbarBloc, TabberState>(
      buildWhen: (previous, current) => (current is OnlineStatusUpdateState ||
          current is OnlineSwitchLoadingTabberState),
      builder: (context, state) {
        final bloc = context.read<TabbarBloc>();
        return FittedBox(
            child: Column(
          children: [
            CupertinoSwitch(
                value: AppStorage().isDutyStarted,
                onChanged: (newVal) async {
                  if (state is OnlineSwitchLoadingTabberState) {
                    return;
                  }
                  final XFile? image =
                      await context.pushNamed(AppPaths.checkin);
                  if (newVal) {
                    bloc.add(StartDutyStatusTabberEvent(image));
                  } else {
                    bloc.add(EndDutyStatusTabberEvent(image));
                  }
                  if (context.mounted) {
                    Scaffold.of(context).closeDrawer();
                  }
                }),
            Text(
              state is OnlineSwitchLoadingTabberState
                  ? "Loading.."
                  : AppStorage().isDutyStarted
                      ? "On-Duty"
                      : "Off-Duty",
              style: const TextStyle(color: Colors.white),
            )
          ],
        ));
      },
    );
  }

  void closeDrawerAndPushView(BuildContext context, String path) {
    Scaffold.of(context).closeDrawer();
    context.pushNamed(path);
  }
}
