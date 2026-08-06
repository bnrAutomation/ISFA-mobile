import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/ui/dialog_view.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upgrader/upgrader.dart';
import 'bloc/tabbar_bloc.dart';
import 'models/side_menu_model.dart';

class AppSideMenu extends StatelessWidget {
  final SideMenuModel data;
  const AppSideMenu({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TabbarBloc>();
    final userDetail = AppStorage().userDetail;
    final name = userDetail?.fullName ?? 'NA';
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final showDuty = userDetail?.userConfiguration.requiredStartDuty == true ||
        userDetail?.configuration.requiredStartDuty == true;

    final drawerWidth = (1.sw * 0.82).clamp(268.0, 320.0);

    return Drawer(
      width: drawerWidth,
      backgroundColor: cs.surface,
      child: UpgradeAlert(
        upgrader:
            Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
        shouldPopScope: () => false,
        showIgnore: false,
        showLater: false,
        navigatorKey: router.routerDelegate.navigatorKey,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SideMenuProfileHeader(
                name: name,
                companyName: userDetail?.companyName ?? 'NA',
                photoUrl: userDetail?.photoUrl ?? '',
                onPrimary: cs.onPrimary,
                primaryColor: theme.primaryColor,
                dutySection: showDuty ? dutyStatus() : null,
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 10.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _menuItemCount(),
                  separatorBuilder: (_, __) => SizedBox(height: 3.h),
                  itemBuilder: (context, index) {
                    return _buildMenuItem(context, bloc, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _menuItemCount() {
    final n = data.sideMenu.where((e) => e.active).length;
    return n + 4;
  }

  Widget _buildMenuItem(BuildContext context, TabbarBloc bloc, int index) {
    final theme = Theme.of(context);
    final active = data.sideMenu.where((e) => e.active).toList();
    if (index < active.length) {
      final e = active[index];
      return _SideMenuNavTile(
        icon: getIcon(e.key.trim()),
        label: e.name,
        dense: true,
        onTap: () {
          switch (e.key.trim().toLowerCase()) {
            case 'promoter':
              closeDrawerAndPushView(context, AppPaths.promoter, e.name);
              break;
            case 'leave':
              closeDrawerAndPushView(context, AppPaths.leave, e.name);
              break;
            case 'attendance':
              closeDrawerAndPushView(context, AppPaths.attendance, e.name);
              break;
            case 'myactivity':
            case 'my-activity':
              closeDrawerAndPushView(context, AppPaths.myActivity, e.name);
              break;
            case 'assessment':
              closeDrawerAndPushView(
                  context, AppPaths.assessmentList, e.name);
              break;
            case 'survey':
              closeDrawerAndPushView(context, AppPaths.surveyList, e.name);
              break;
            case 'issus_management':
            case 'issue_management':
              closeDrawerAndPushView(
                  context, AppPaths.issuesManagement, e.name);
              break;
            case 'help':
              closeDrawerAndOpenHelp(context);
              break;
            default:
              Navigator.pop(context);
          }
        },
      );
    }
    final i = index - active.length;
    if (i == 0) {
      return _SideMenuNavTile(
        icon: Icons.fact_check_outlined,
        label: 'Assessment',
        dense: true,
        onTap: () => closeDrawerAndPushView(
            context, AppPaths.assessmentList, 'Assessment'),
      );
    }
    if (i == 1) {
      return _SideMenuNavTile(
        icon: Icons.settings_outlined,
        label: 'Settings',
        dense: true,
        onTap: () =>
            closeDrawerAndPushView(context, AppPaths.setting, 'Settings'),
      );
    }
    if (i == 2) {
      return _SideMenuNavTile(
        icon: Icons.help_outline,
        label: 'Help',
        dense: true,
        onTap: () => closeDrawerAndOpenHelp(context),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 4.h),
          child: Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.28),
          ),
        ),
        _SideMenuNavTile(
          icon: Icons.logout_rounded,
          label: 'Logout',
          dense: true,
          danger: true,
          onTap: () {
            Scaffold.of(context).closeDrawer();
            showGeneralDialog(
                context: context,
                pageBuilder: (context, _, __) => DialogView(
                      title: 'Logout',
                      description: 'Do you want to logout?',
                      okayButtonText: 'Logout',
                      onDelete: () async {
                        context.pop();
                        bloc.add(LogoutEvent());
                      },
                    ));
          },
        ),
      ],
    );
  }

  IconData getIcon(String key) {
    switch (key.toLowerCase()) {
      case 'promoter':
        return Icons.account_box_outlined;
      case 'leave':
        return Icons.directions_walk_outlined;
      case 'attendance':
        return Icons.verified_outlined;
      case 'myactivity':
      case 'my-activity':
        return Icons.schedule_outlined;
      case 'assessment':
        return Icons.assessment_outlined;
      case 'survey':
        return Icons.calculate_outlined;
      case 'analytics':
        return Icons.pie_chart_outline;
      case 'learn':
        return Icons.book_online_outlined;
      case 'myschedule':
        return Icons.calendar_month_outlined;
      case 'campaign':
        return Icons.campaign_outlined;
      case 'issus_management':
      case 'issue_management':
        return Icons.precision_manufacturing_outlined;
      case 'help':
        return Icons.help_outline;

      default:
        return Icons.emoji_emotions;
    }
  }

  Widget dutyStatus() {
    return BlocBuilder<TabbarBloc, TabbarState>(
      buildWhen: (previous, current) => (current is OnlineStatusUpdateState),
      builder: (context, state) {
        final bloc = context.read<TabbarBloc>();
        return Material(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Duty',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(width: 8.w),
                CupertinoSwitch(
                  value: AppStorage().isDutyStarted,
                  onChanged: (newVal) async {
                    final XFile? image = (AppStorage()
                                .userDetail
                                ?.configuration
                                .requiredSelfieForStartDuty ??
                            true)
                        ? await context.pushNamed(AppPaths.checkin)
                        : null;

                    showGeneralDialog(
                        context: context,
                        pageBuilder: (context, _, __) => DialogView(
                              title: newVal ? 'On-Duty?' : 'Off-Duty?',
                              description: newVal
                                  ? 'Do you want to On-Duty?'
                                  : 'Do you want to Off-Duty?',
                              okayButtonText: newVal ? 'On-Duty' : 'Off-Duty',
                              onDelete: () async {
                                context.pop();
                                if (newVal) {
                                  bloc.add(
                                      StartDutyStatusTabbarEvent(image, context));
                                } else {
                                  bloc.add(
                                      EndDutyStatusTabbarEvent(image, context));
                                }
                              },
                            ));

                    if (context.mounted) {
                      Scaffold.of(context).closeDrawer();
                    }
                  },
                ),
                SizedBox(width: 8.w),
                Text(
                  AppStorage().isDutyStarted ? 'On' : 'Off',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppStorage().isDutyStarted? Colors.green: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void closeDrawerAndPushView(BuildContext context, String path, String name) {
    Scaffold.of(context).closeDrawer();
    context.pushNamed(path, pathParameters: {
      'name': name,
    });
  }

  void closeDrawerAndOpenHelp(BuildContext context) {
    Scaffold.of(context).closeDrawer();
    context.pushNamed(AppPaths.help);
  }
}

class _SideMenuProfileHeader extends StatelessWidget {
  final String name;
  final String companyName;
  final String photoUrl;
  final Color onPrimary;
  final Color primaryColor;
  final Widget? dutySection;

  const _SideMenuProfileHeader({
    required this.name,
    required this.companyName,
    required this.photoUrl,
    required this.onPrimary,
    required this.primaryColor,
    this.dutySection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: primaryColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: onPrimary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => CachedNetworkImage(
                        imageUrl: ImageConstants.placeholderUserUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: onPrimary,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        companyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onPrimary.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (dutySection != null) ...[
              SizedBox(height: 10.h),
              dutySection!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SideMenuNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool dense;

  const _SideMenuNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = danger ? cs.error : cs.onSurface;
    final iconBg = danger
        ? cs.errorContainer.withValues(alpha: 0.55)
        : cs.primaryContainer.withValues(alpha: 0.5);
    final vPad = dense ? 8.h : 11.h;
    final hPad = dense ? 10.w : 12.w;
    final iconBox = dense ? 34.w : 38.w;
    final iconSz = dense ? 18.sp : 20.sp;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.28),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Row(
            children: [
              SizedBox(
                width: iconBox,
                height: iconBox,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: fg, size: iconSz),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: fg,
                    height: 1.2,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.45),
                size: dense ? 20.sp : 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
