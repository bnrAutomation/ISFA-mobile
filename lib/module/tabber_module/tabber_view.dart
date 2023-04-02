import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:i_densfa/module/campaign_module/campaign_view.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/module/tabber_module/tabbar_repository.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';

import '../../utility/network_helper.dart';
import '../beat_plan_module/beat_plan_view.dart';
import '../store_list_module/store_list_view.dart';
import 'bloc/tabber_bloc.dart';

class TabberView extends StatelessWidget {
  const TabberView({super.key});
  static const TextStyle optionStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w600);

  static const List<Widget> widgetOptions = <Widget>[
    StoreListView(),
    Text(
      'Learner',
      style: optionStyle,
    ),
    BeatPlanView(),
    CampaignView(),
    Text(
      'Analytics',
      style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    BuildContext? networkAlertContext;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => TabberBloc(TabbarRepository())
              ..add(UpdateSideMenuDetailsEvent())),
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
            return Scaffold(
              drawer: context.read<TabberBloc>().sideMenuData == null
                  ? null
                  : AppSideMenu(data: context.read<TabberBloc>().sideMenuData!),
              appBar: AppBar(
                title: Text(context.read<TabberBloc>().tabTitle()),
                leading: Builder(
                    builder: (context) => IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(
                          Icons.blur_on_sharp,
                          color: Colors.black,
                        ))),
              ),
              body: Center(
                child: widgetOptions[context.read<TabberBloc>().selectIndex],
              ),
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
                    //iconSize: 24,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    curve: Curves.linear,
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.white,
                    tabs: const [
                      GButton(
                        icon: Icons.calendar_month_outlined,
                        text: 'My Schedule',
                      ),
                      GButton(
                        icon: Icons.book_online,
                        text: 'Learner',
                      ),
                      GButton(
                        icon: Icons.leaderboard_outlined,
                        text: 'Leaderboard',
                      ),
                      GButton(
                        icon: Icons.campaign_outlined,
                        text: 'Campaign',
                      ),
                      GButton(
                        icon: Icons.pie_chart_outline,
                        text: 'Analytics',
                      ),
                    ],

                    selectedIndex: context.read<TabberBloc>().selectIndex,
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
              currentAccountPicture: const CircleAvatar(),
              otherAccountsPictures: [
                BlocBuilder<TabberBloc, TabberState>(
                  buildWhen: (previous, current) =>
                      (current is OnlineStatusUpdateState),
                  builder: (context, state) {
                    return FittedBox(
                      child: Column(
                        children: [
                          CupertinoSwitch(
                              value: context.read<TabberBloc>().isOnline,
                              onChanged: (newVal) => closeDrawerAndPushView(
                                  context, AppPaths.checkin)),
                          Text(
                            context.read<TabberBloc>().isOnline
                                ? "On-Duty"
                                : "Off-Duty",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
              accountName: Text(data.userInfo.companyName),
              accountEmail: Text(data.userInfo.userName)),
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
                  switch (e.key) {
                    case 'promoter':
                      closeDrawerAndPushView(context, AppPaths.promoter);
                      break;
                    case 'leave':
                      closeDrawerAndPushView(context, AppPaths.leave);
                      break;
                    case 'attendance':
                      Navigator.pop(context);
                      break;
                    case 'My Activities':
                      closeDrawerAndPushView(context, AppPaths.activity);
                      break;
                    case 'Assessment':
                      closeDrawerAndPushView(context, AppPaths.assessmentList);
                      break;
                    default:
                      Navigator.pop(context);
                  }
                },
              );
            },
          ).toList(),
          ListTile(
            leading: const Icon(Icons.logout),
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

  void closeDrawerAndPushView(BuildContext context, String path) {
    Scaffold.of(context).closeDrawer();
    context.pushNamed(path);
  }
}
