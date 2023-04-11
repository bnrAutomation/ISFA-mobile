import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_store_list_view.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_stores_repository.dart';
import 'package:i_densfa/module/beatplan_stores_module/bloc/beatplan_stores_bloc.dart';
import 'package:i_densfa/module/campaign_module/campaign_view.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/module/tabber_module/tabbar_repository.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../utility/network_helper.dart';
import '../beat_plan_module/beat_plan_view.dart';
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
            final bloc = context.read<TabberBloc>();

            return Scaffold(
              drawer: bloc.sideMenuData == null
                  ? null
                  : AppSideMenu(data: bloc.sideMenuData!),
              appBar: AppBar(
                title: Text(bloc.tabTitle()),
                leading: BlocListener<TabberBloc, TabberState>(
                  listenWhen: (previous, current) =>
                      current is TabbarSnackBarMessageState,
                  listener: (context, state) {
                    if (state is TabbarSnackBarMessageState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
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

  Widget atSelectedIndex(TabberBloc bloc) {
    switch (bloc.selectIndex) {
      case 0:
        return (bloc.sideMenuData == null)
            ? const CircularProgressIndicator()
            : BlocProvider(
                create: (context) =>
                    BeatplanStoresBloc(BeatPlanStoresRepository(1))
                      ..add(BeatPlanStoresUpdateData()),
                child: const BeatPlanStoreListView(),
              );

      case 1:
        return const Text(
          'Learner',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        );

      case 2:
        return const BeatPlanView();
      case 3:
        return const CampaignView();
      case 4:
        return const Text(
          'Analytics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        );
      default:
        return const SizedBox();
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
              currentAccountPicture: const CircleAvatar(),
              otherAccountsPictures: [
                BlocBuilder<TabberBloc, TabberState>(
                  buildWhen: (previous, current) =>
                      (current is OnlineStatusUpdateState),
                  builder: (context, state) {
                    final bloc = context.read<TabberBloc>();
                    return FittedBox(
                      child: Column(
                        children: [
                          CupertinoSwitch(
                              value: bloc.isOnline,
                              onChanged: (newVal) async {
                                Scaffold.of(context).closeDrawer();
                                final XFile? image =
                                    await context.pushNamed(AppPaths.checkin);
                                if (newVal) {
                                  bloc.add(StartDutyStatusTabberEvent(image));
                                } else {
                                  bloc.add(EndDutyStatusTabberEvent(image));
                                }
                              }),
                          Text(
                            bloc.isOnline ? "On-Duty" : "Off-Duty",
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
              if (e.key == "promoter" &&
                  AppStorage().userDetail?.designation == "fwp") {
                return const SizedBox();
              }
              return ListTile(
                leading: const Icon(Icons.logout),

                //  CachedNetworkImage(
                //   fit: BoxFit.contain,
                //   imageUrl: e.icon,
                //   width: 25.w,
                //   height: 25.w,
                //   errorWidget: (context, url, error) =>
                //       const ColoredBox(color: Colors.red),
                // ),
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
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('My Activities'),
            onTap: () {
              closeDrawerAndPushView(context, AppPaths.activity);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Setting'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.live_help_outlined),
            title: const Text('Query'),
            onTap: () {
              Scaffold.of(context).closeDrawer();
            },
          ),
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
