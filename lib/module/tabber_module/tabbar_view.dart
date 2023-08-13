import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:i_densfa/module/analytics_module/analytics_view.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_store_list_view.dart';
import 'package:i_densfa/module/beatplan_stores_module/beatplan_stores_repository.dart';
import 'package:i_densfa/module/beatplan_stores_module/bloc/beatplan_stores_bloc.dart';
import 'package:i_densfa/module/campaign_module/view/campaign_view.dart';
import 'package:i_densfa/module/learner_module/learner_view.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/module/tabber_module/side_menu_view.dart';
import 'package:i_densfa/module/tabber_module/tabbar_repository.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../../utility/network_helper.dart';
import 'bloc/tabber_bloc.dart';

class TabbarView extends StatelessWidget {
  const TabbarView({super.key});

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
          if (state is NetworkFailure && Platform.isAndroid) {
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
