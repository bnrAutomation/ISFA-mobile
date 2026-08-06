import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:i_densfa/module/analytics_module/analytics_view.dart';
import 'package:i_densfa/module/campaign_module/view/campaign_view.dart';
import 'package:i_densfa/module/learner_module/learner_view.dart';
import 'package:i_densfa/module/my_schedule_module/my_schedule_view.dart';
import 'package:i_densfa/module/my_store_module/my_store_view.dart';
import 'package:i_densfa/module/setting_module/setting_view.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/module/tabber_module/side_menu_view.dart';
import 'package:i_densfa/module/tabber_module/tabbar_repository.dart';
import 'package:i_densfa/module/ui/dialog_view.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../../utility/network_helper.dart';
import 'bloc/tabbar_bloc.dart';

class AppTabbarView extends StatelessWidget {
  const AppTabbarView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => TabbarBloc(context, TabbarRepository())
              ..add(UpdateSideMenuDetailsEvent())),
        BlocProvider(
          create: (context) => NetworkBloc()..add(NetworkObserve()),
        ),
      ],
      child: BlocConsumer<TabbarBloc, TabbarState>(
        listener: (context, state) {
          if (state is ShowSectionPopUpState) {
            showGeneralDialog(
                context: context,
                pageBuilder: (context, _, __) => DialogView(
                      title: state.title,
                      description: state.message,
                      okayButtonText: "Logout",
                      onDelete: () async {
                        context.pop();
                        AppStorage().logout();
                        context.pushReplacement(AppPaths.initial);
                      },
                    ));
          }
          if (state is LogoutSuccessfulState) {
            AppStorage().logout();
            context.go(AppPaths.login);
          }
          if (state is ResetPasswordState) {
            context.go(AppPaths.changePass);
          }
        },
        builder: (context, state) {
          final bloc = context.read<TabbarBloc>();
          return Stack(
            children: [
              Scaffold(
                
                drawer: bloc.sideMenuData == null
                    ? null
                    : AppSideMenu(data: bloc.sideMenuData!),
                appBar: AppBar(
                  title: Text(bloc.tabbarItems[bloc.selectIndex].navTitle()),
                  leading: BlocListener<TabbarBloc, TabbarState>(
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
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                              icon: const Icon(Icons.blur_on_sharp));
                    }),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => context.push(AppPaths.notification),
                      icon: Badge(
                          backgroundColor: Colors.black,
                          isLabelVisible: AppConstant.notificationCount != 0,
                          label: Text(
                            AppConstant.notificationCount.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          child: const Icon(Icons.notifications_outlined)),
                    ),
                  ],
                ),
                body: PageTransitionSwitcher(
                  duration: const Duration(seconds: 1),
                  transitionBuilder: (child, animation, secondAnimation) =>
                      FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secondAnimation,
                    child: child,
                  ),
                  child: atSelectedIndex(bloc),
                ),
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Material(
                      color: Colors.amber,
                      elevation: 20,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: GNav(
                          rippleColor:
                              Colors.black.withValues(alpha: 0.06),
                          hoverColor:
                              Colors.black.withValues(alpha: 0.04),
                          gap: 6,
                          iconSize: 22,
                          activeColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          curve: Curves.easeOutCubic,
                          duration: const Duration(milliseconds: 220),
                          tabBorderRadius: 18,
                          tabBackgroundColor:
                              Colors.white,
                          color: Colors.black.withValues(alpha: 0.55),
                          // textStyle: const TextStyle(
                          //   color: Colors.black,
                          //   fontWeight: FontWeight.bold,
                          //   fontSize: 12,
                          // ),
                          tabs: bloc.tabbarItems
                              .map(
                                (e) => GButton(
                                  iconColor: Colors.black,
                                  icon: tabIcon(e),
                                  text: e.bottomTitle(),
                                ),
                              )
                              .toList(),
                          selectedIndex: bloc.selectIndex,
                          onTabChange: (index) {
                            bloc.add(ChangeTabEvent(index));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (state is TabbarShowProgressHudState) const ProgressHudView()
            ],
          );
        },
      ),
    );
  }

  IconData tabIcon(TabbarItemCase item) {
    switch (item) {
       case TabbarItemCase.mystore:
        return Icons.store_outlined;
      case TabbarItemCase.schedule:
        return Icons.calendar_month_outlined;
      case TabbarItemCase.learner:
        return Icons.book_online;
      case TabbarItemCase.campaign:
        return Icons.campaign_outlined;
      case TabbarItemCase.analytics:
        return Icons.pie_chart_outline;
      case TabbarItemCase.settings:
        return Icons.settings_outlined;
    }
  }

  Widget atSelectedIndex(TabbarBloc bloc) {
    final tab = bloc.tabbarItems[bloc.selectIndex];
    switch (tab) {
      case TabbarItemCase.mystore:
        return (bloc.sideMenuData == null)
            ? const Center(child: CircularProgressIndicator())
            : const MyStoreView();
      case TabbarItemCase.schedule:
        return (bloc.sideMenuData == null)
            ? const Center(child: CircularProgressIndicator())
            : const MyScheduleView();
      case TabbarItemCase.learner:
        return const LearnerView();
      case TabbarItemCase.campaign:
        return const CampaignView(
          retailerName: "",
          mechanicsContact: "",
          mechanicsName: "",
          storeId: -1, from: AppPaths.tabbar,storeLat:0.0,storeLong:0.0);
      case TabbarItemCase.analytics:
        return const AnalyticsView();
      case TabbarItemCase.settings:
        return const SettingView(name: "Settings");
    }
  }
}

class ProgressHudView extends StatelessWidget {
  const ProgressHudView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Material(
      color: Colors.white10,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(16)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text(
                'Loading...',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
