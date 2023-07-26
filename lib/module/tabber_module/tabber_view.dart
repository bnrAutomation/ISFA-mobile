import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:i_densfa/module/analytics_module/analytics_view.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_store_list_view.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_stores_repository.dart';
import 'package:i_densfa/module/beatplan_stores_module/bloc/beatplan_stores_bloc.dart';
import 'package:i_densfa/module/campaign_module/view/campaign_view.dart';
import 'package:i_densfa/module/learner_module/learner_view.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/module/tabber_module/tabbar_repository.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:image_picker/image_picker.dart';

import '../../utility/network_helper.dart';
import 'bloc/tabber_bloc.dart';

class TabberView extends StatelessWidget {
  const TabberView({super.key});

  @override
  Widget build(BuildContext context) {
    BuildContext? networkAlertContext;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => TabberBloc(TabbarRepository())
              ..add(UpdateSideMenuDetailsEvent())
              ..add(SubmitToken())),
        BlocProvider(
          create: (context) => NetworkBloc()..add(NetworkObserve()),
        ),
      ],
      child: BlocListener<NetworkBloc, NetworkState>(
        listener: (c, state) {
          if (state is NetworkFailure) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) {
                  networkAlertContext = c;
                  return const AlertDialog(
                    content: Text("No Internet Connection"),
                  );
                });
          } else {
            if (networkAlertContext != null) {
              Navigator.pop(networkAlertContext!);
            }
          }
        },
        child: BlocBuilder<TabberBloc, TabberState>(
          builder: (context, state) {
            final bloc = context.read<TabberBloc>();

            return Scaffold(
              drawer: bloc.sideMenuData == null
                  ? null
                  : AppSideMenu(data: bloc.sideMenuData!),
              appBar: AppBar(
                title: Text(bloc.tabberItems[bloc.selectIndex].navTitle()),
                leading: BlocListener<TabberBloc, TabberState>(
                  listenWhen: (previous, current) =>
                      current is TabbarSnackBarMessageState,
                  listener: (context, state) {
                    if (state is TabbarSnackBarMessageState) {
                      context.showSnackBarMessage(state.message);
                    }
                  },
                  child: Builder(builder: (context) {
                    return (bloc.sideMenuData == null)
                        ? const SizedBox()
                        : IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: const Icon(
                              Icons.blur_on_sharp,
                              color: Colors.black,
                            ));
                  }),
                ),
                actions: [
                  IconButton(
                      onPressed: () => context.push(AppPaths.notification),
                      icon: const Icon(Icons.notifications))
                ],
              ),
              body: Center(child: atSelectedIndex(bloc)),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.white.withOpacity(.1),
                    )
                  ],
                ),
                child: SafeArea(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
                  child: GNav(
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,
                    gap: 6,
                    activeColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    curve: Curves.linear,
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.white,
                    tabs: bloc.tabberItems
                        .map((e) =>
                            GButton(icon: tabIcon(e), text: e.bottomTitle()))
                        .toList(),
                    selectedIndex: bloc.selectIndex,
                    onTabChange: (index) {
                      BlocProvider.of<TabberBloc>(context)
                          .add(ChangeTabEvent(index));
                    },
                  ),
                )),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData tabIcon(TabbarItemCase item) {
    switch (item) {
      case TabbarItemCase.schedule:
        return Icons.calendar_month_outlined;
      case TabbarItemCase.learner:
        return Icons.book_online;
      case TabbarItemCase.campaign:
        return Icons.campaign_outlined;
      case TabbarItemCase.analytics:
        return Icons.pie_chart_outline;
    }
  }

  Widget atSelectedIndex(TabberBloc bloc) {
    final tab = bloc.tabberItems[bloc.selectIndex];
    switch (tab) {
      case TabbarItemCase.schedule:
        return (bloc.sideMenuData == null)
            ? const CircularProgressIndicator()
            : BlocProvider(
                create: (context) => BeatplanStoresBloc(
                    BeatPlanStoresRepository(
                        bloc.sideMenuData!.userInfo.companyId))
                  ..add(BeatPlanStoresUpdateData()),
                child: const BeatPlanStoreListView(),
              );
      case TabbarItemCase.learner:
        return const LearnerView();
      case TabbarItemCase.campaign:
        return const CampaignView();
      case TabbarItemCase.analytics:
        return const AnalyticsView();
    }
  }
}

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
                backgroundImage: NetworkImage(AppStorage()
                        .userDetail!
                        .photoUrl
                        .contains('http')
                    ? AppStorage().userDetail!.photoUrl
                    : "https://tastevibe.web.app/assets/images/placeholder-user.png"),
                backgroundColor: Colors.grey.withOpacity(0.2),
              ),
              otherAccountsPictures: [dutyStatus()],
              accountName: Text(
                  "${data.userInfo.userName} (${data.userInfo.designation})"),
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
          if (data.userInfo.designation != 'fwp')
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Team'),
              onTap: () {
                Scaffold.of(context).closeDrawer();
              },
            ),
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
              AppStorage().userDetail = null;
              context.go(AppPaths.login);
            },
          ),
        ],
      ),
    );
  }

  Widget dutyStatus() {
    return BlocBuilder<TabberBloc, TabberState>(
      buildWhen: (previous, current) => (current is OnlineStatusUpdateState ||
          current is OnlineSwitchLoadingTabberState),
      builder: (context, state) {
        final bloc = context.read<TabberBloc>();
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
