import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:i_densfa/module/campaign_module/campaign_view.dart';
import 'package:i_densfa/module/tabber_module/tabber/tabber_bloc.dart';
import 'package:i_densfa/routes.dart';

import '../beat_plan_module/beat_plan_view.dart';
import '../store_list_module/store_list_view.dart';

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
    return BlocProvider(
      create: (context) => TabberBloc(),
      child: BlocBuilder<TabberBloc, TabberState>(
        builder: (context, state) {
          return Scaffold(
            drawer: const AppSideMenu(),
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
              child: widgetOptions[
                  BlocProvider.of<TabberBloc>(context).selectIndex],
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
    );
  }
}

class AppSideMenu extends StatelessWidget {
  const AppSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
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
              accountName: const Text("Gopal Krishan"),
              accountEmail: const Text("ce.gopal@denave.com")),
          ListTile(
            leading: const Icon(CupertinoIcons.calendar_today),
            title: const Text('Attendance'),
            onTap: () => context.pop(),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('My Activities'),
            onTap: () => closeDrawerAndPushView(context, AppPaths.activity),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Leave'),
            onTap: () => closeDrawerAndPushView(context, AppPaths.leave),
          ),
          ListTile(
            leading: const Icon(Icons.handshake_outlined),
            title: const Text('Promoter'),
            onTap: () => closeDrawerAndPushView(context, AppPaths.promoter),
          ),
          ListTile(
            leading: const Icon(Icons.assessment_outlined),
            title: const Text('Assessment'),
            onTap: () =>
                closeDrawerAndPushView(context, AppPaths.assessmentList),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
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
