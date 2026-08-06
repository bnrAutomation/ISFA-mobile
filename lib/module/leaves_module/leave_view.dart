import 'package:circular_progress_bar_with_lines/circular_progress_bar_with_lines.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/leaves_module/apply_leave_form_view.dart';
import 'package:i_densfa/module/leaves_module/leave/leave_bloc.dart';
import 'package:i_densfa/module/leaves_module/model/leave_model.dart';
import 'package:i_densfa/module/leaves_module/optional_view.dart';
import 'package:i_densfa/module/ui/dialog_helper.dart';
import 'package:i_densfa/module/ui/gradient_button.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:upgrader/upgrader.dart';

import '../ui/app_tabview_view.dart';
import 'leave_repository.dart';
import 'model/leave_enums.dart';

class LeaveView extends StatelessWidget {
  final String name;
  const LeaveView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: Scaffold(
        //  backgroundColor: Theme.of(context).colorScheme.onSurface,
        appBar: AppBar(
          title: Text(name),
          elevation: 0,
        ),
        body: RepositoryProvider(
          create: (context) => LeaveRepository(),
          child: BlocProvider(
            create: (context) => LeaveBloc(context.read())
              ..add(GetLeaveBalanceEvent())
              ..add(GetLeaveDetailsEvent())
              ..add(GetUpcommingLeave())
              ..add(GetWeekOffLeave())
              ..add(GetOptionalLeave())..add(GetLeaveList()),
            child: BlocConsumer<LeaveBloc, LeaveState>(
              listenWhen: (previous, current) => current is LeaveViewShowSnack,
              listener: (context, state) {
                if (state is LeaveViewShowSnack) {
                  DialogHelper.showErrorMessage(
                      context, "Alert", state.message);
                  // context.showSnackBarMessage(state.message);
                }
              },
              buildWhen: (previous, current) => current is! LeaveViewShowSnack,
              builder: (context, state) {
                if (state is LeaveViewLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bloc = context.read<LeaveBloc>();
                List<LeaveBalanceModel> leaveBalnc = bloc.leaveTypeBalance
  .where((element) => element.leaveTypeName.toLowerCase().trim() != "weekly off")
  .toList();

              //  List<LeaveBalanceModel> leaveBalnc =   bloc.leaveTypeBalance.map<LeaveBalanceModel>((element)=>element.leaveTypeName.toLowerCase().trim()!= "weekly off".trim()).toList();
                return SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                          delegate: SliverChildListDelegate.fixed([
                        SizedBox(height: 8.h),
                        (AppStorage()
                                    .userDetail
                                    ?.userConfiguration
                                    .requiredApplyLeave ??
                                true)
                            ? AppStorage().userDetail?.companyName ==
                                        "BrotherInternational" ||
                                    AppStorage().userDetail?.companyName ==
                                        "Mobil" || AppStorage().userDetail?.companyName.toLowerCase()=="ExxonMobil Mobile Miles Plant".toLowerCase()
                                ? leaveApplyCard(context, bloc, textTheme)
                                : leaveBalanceCard(context, bloc, textTheme)
                            : const SizedBox(),
                        SizedBox(height: 6.h),
                        (AppStorage()
                                    .userDetail
                                    ?.userConfiguration
                                    .requiredApplyLeave ??
                                true)
                            ? leaveBalnc.isNotEmpty
                                ? Container(
                                    constraints: BoxConstraints(
                                        minWidth: 1.sw, maxHeight: 130),
                                    padding: EdgeInsets.only(left: 12.w, right: 4.w),
                                    child: AnimationLimiter(
                                      child: ListView.builder(
                                        itemCount: leaveBalnc.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) =>
                                            AnimationConfiguration
                                                .staggeredList(
                                          position: index,
                                          duration:
                                              const Duration(milliseconds: 375),
                                          child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                  child: _leaveTypeBalance(
                                                      context, index,leaveBalnc))),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox()
                            : const SizedBox(),
                        (AppStorage()
                                    .userDetail
                                    ?.userConfiguration
                                    .requiredUpcommingHoliday ??
                                true)
                            ? bloc.upcommingLeave.isNotEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            16.w, 12.h, 16.w, 8.h),
                                        child: Text(
                                          'Upcoming holidays',
                                          textAlign: TextAlign.center,
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      Card(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.14),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 12.w),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .dividerColor
                                                  .withValues(alpha: 0.25),
                                            ),
                                          ),
                                          elevation: 0,
                                          clipBehavior: Clip.antiAlias,
                                          child: AnimationLimiter(
                                            child: GridView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 12.h,
                                                  crossAxisSpacing: 12.w,
                                                  childAspectRatio: 0.72,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 18.h),
                                                itemCount:
                                                    bloc.upcommingLeave.length,
                                                itemBuilder: (context, index) {
                                                  return AnimationConfiguration
                                                      .staggeredGrid(
                                                    position: index,
                                                    duration: const Duration(
                                                        milliseconds: 600),
                                                    columnCount: 4,
                                                    child: ScaleAnimation(
                                                      child: FadeInAnimation(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            AspectRatio(
                                                              aspectRatio: 1,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .surface
                                                                      .withValues(
                                                                          alpha:
                                                                              0.85),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border.all(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .dividerColor
                                                                        .withValues(
                                                                            alpha:
                                                                                0.5),
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Text(
                                                                      bloc
                                                                              .upcommingLeave[
                                                                                  index]
                                                                              .date
                                                                              ?.day
                                                                              .toString() ??
                                                                          '',
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .titleLarge
                                                                          ?.copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                            color:
                                                                                Theme.of(context).colorScheme.onSurface,
                                                                          ),
                                                                    ),
                                                                    Text(
                                                                      bloc
                                                                              .upcommingLeave[index]
                                                                              .date
                                                                              ?.toStringFormat('MMM') ??
                                                                          '',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .labelLarge
                                                                          ?.copyWith(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                Theme.of(context).colorScheme.onSurfaceVariant,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 8.h),
                                                            Text(
                                                              bloc
                                                                  .upcommingLeave[
                                                                      index]
                                                                  .name,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .labelMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    height:
                                                                        1.2,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurface,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ))
                                    ],
                                  )
                                : const SizedBox()
                            : const SizedBox()
                      ])),
                      SliverFillRemaining(
                          child: AppTabViewController(
                        backgroundColor: Colors.transparent,
                        initialIndex: bloc.bottomTabSelectedIndex,
                        onTabTap: (p0) => bloc.bottomTabSelectedIndex = p0,
                        titles: bloc.tabbarTitles,
                        children: bloc.tabbarLeavesList.map((leaves) {
                          return bloc.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : bloc.tabbarTitles.isNotEmpty
                                  ? AnimationLimiter(
                                      child: ListView.separated(
                                          itemCount: leaves.length,
                                          padding: EdgeInsets.fromLTRB(
                                              10.w, 8.h, 10.w, 16.h),
                                          separatorBuilder: (context, index) =>
                                              SizedBox(height: 8.h),
                                          itemBuilder: (c, index) =>
                                              AnimationConfiguration
                                                  .staggeredList(
                                                position: index,
                                                duration: const Duration(
                                                    milliseconds: 375),
                                                child: SlideAnimation(
                                                    verticalOffset: 40.0,
                                                    child: FadeInAnimation(
                                                        child: ApproveLeave(
                                                            leaves[index]))),
                                              )),
                                    )
                                  : const SizedBox();
                        }).toList(),
                      ))
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget leaveApplyCard(
      BuildContext context, LeaveBloc bloc, TextTheme textTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: SizedBox(
        height: 0.2.sh,
        child: Row(
          children: [
            Expanded(
              child: GradientButton(
                text: 'Apply\navailable leave',
                hight: double.infinity,
                onPressed: () {
                  AppPopup.showAppBottomSheet(
                    context: context,
                    child: BlocProvider.value(
                      value: bloc..add(GetLeaveTypes()),
                      child: const ApplyLeaveFormView(),
                    ),
                  );
                },
                gradient: const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            bloc.optionalLeave.isEmpty
                ? const SizedBox()
                : Expanded(
                    child: GradientButton(
                      text: 'Apply\noptional leave',
                      hight: double.infinity,
                      onPressed: () {
                        AppPopup.showAppBottomSheet(
                          context: context,
                          child: BlocProvider.value(
                            value: bloc,
                            child: const OptionalLeaveView(),
                          ),
                        );
                      },
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA000), Color(0xFFFFD54F)],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Card leaveBalanceCard(
      BuildContext context, LeaveBloc bloc, TextTheme textTheme) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primary.withValues(alpha: 0.12),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        child: AnimationLimiter(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              SizedBox(height: 4.h),
              InkWell(
                onTap: () {
                  AppPopup.showAppBottomSheet(
                    context: context,
                    child: BlocProvider.value(
                      value: bloc..add(GetLeaveTypes()),
                      child: const ApplyLeaveFormView(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        RotationTransition(
                          turns: AlwaysStoppedAnimation(bloc.fadeRotatedAngle),
                          child: SizedBox(
                            width: bloc.fadeCirlceDiameter,
                            height: bloc.fadeCirlceDiameter,
                            child: CircularProgressIndicator(
                              value: bloc.incompleteLeavePercent,
                              color: Colors.grey.shade500,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        CircularProgressBarWithLines(
                          radius: bloc.circleRadius,
                          percent: bloc.completeLeavePercent,
                          linesAmount: 80,
                          linesLength: 20,
                          linesColor: Theme.of(context).primaryColor,
                          centerWidgetBuilder: (context) => AppStorage()
                                      .userDetail
                                      ?.companyName ==
                                  "BrotherInternational"
                              ? const SizedBox()
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      (bloc.details?.leaveBalance ?? 0.0)
                                          .toString(),
                                      style: textTheme.headlineLarge?.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Leave balance',
                                      style: textTheme.bodyMedium,
                                    )
                                  ],
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap to apply for leave',
                      style: textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppStorage().userDetail?.companyName ==
                            "BrotherInternational"
                        ? const SizedBox()
                        : Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle,
                                      size: 6,
                                      color: theme.colorScheme.onSurfaceVariant),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Total leave',
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Text(
                                (bloc.details?.totalLeave ?? 0.0).toString(),
                                style: textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                    bloc.optionalLeave.isEmpty
                        ? const SizedBox()
                        : FilledButton.tonal(
                            onPressed: () {
                              AppPopup.showAppBottomSheet(
                                context: context,
                                child: BlocProvider.value(
                                  value: bloc,
                                  child: const OptionalLeaveView(),
                                ),
                              );
                            },
                            child: const Text('Optional leave'),
                          ),
                    AppStorage().userDetail?.companyName ==
                            "BrotherInternational"
                        ? const SizedBox()
                        : Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle,
                                      size: 6,
                                      color: theme.colorScheme.onSurfaceVariant),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Used leave',
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Text(
                                (bloc.details?.usedLeave ?? 0.0).toString(),
                                style: textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        )),
      ),
    );
  }

  Widget _leaveTypeBalance(BuildContext context, int index, List<LeaveBalanceModel> leaveBalnc) {
    final textTheme = Theme.of(context).textTheme;
    final model = leaveBalnc[index];
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
        color: (model.leaveTypeColor).toColor(),
        child: Stack(
        children: [
          SvgPicture.asset(ImageConstants.leavemask, fit: BoxFit.fill),
          Positioned(
              right: 2,
              top: 2,
              child: model.leaveTypeIcon != null
                  ? Container(
                      width: 34.w,
                      height: 34.h,
                      padding: const EdgeInsets.all(5.0),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                      child: Image.network(
                        model.leaveTypeIcon ?? "",
                        color: (model.leaveTypeColor).toColor(),
                      
  errorBuilder: (context, error, stackTrace) {
    return  Icon(Icons.image_not_supported_outlined,color:  (model.leaveTypeColor).toColor(),);
  },
                      ),
                    )
                  : const SizedBox()),
          Positioned(
              left: 4,
              bottom: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ["mobil","exxonmobil mobile miles plant"].contains(AppStorage().userDetail?.companyName.toLowerCase())
                  //AppStorage().userDetail?.companyName != "Mobil" || AppStorage().userDetail?.companyName.toLowerCase()!="ExxonMobil Mobile Miles Plant".toLowerCase()
                      ? 
                      const SizedBox():
                      Text(
                          (model.leaveTypeBalance).toStringAsFixed(2),
                          style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ,
                  Text(
                    model.leaveTypeName,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5)
                ],
              ))
        ],
      ),
    ),
    );
  }
}

class ApproveLeave extends StatelessWidget {
  final AppliedLeaveModel leaveListItem;
  const ApproveLeave(this.leaveListItem, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bloc = context.read<LeaveBloc>();

    Color statusBg(LeaveStatus s) {
      if (s == LeaveStatus.approved) return const Color(0xFF2E7D32);
      if (s == LeaveStatus.rejected) return cs.error;
      return ColorConstants.amber;
    }

    Widget statusControl() {
      if (leaveListItem.userName != null) {
        return FilledButton(
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            backgroundColor: statusBg(leaveListItem.leaveStatus),
          ),
          onPressed: leaveListItem.leaveStatus == LeaveStatus.pending
              ? () => _showResponseOptions(context, bloc)
              : null,
          child: Text(
            leaveListItem.leaveStatus.toStr().toUpperCase(),
            style: TextStyle(
              color: leaveListItem.leaveStatus == LeaveStatus.pending
                  ? Colors.black
                  : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        );
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: statusBg(leaveListItem.leaveStatus).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          leaveListItem.leaveStatus.toStr().toUpperCase(),
          style: TextStyle(
            color: statusBg(leaveListItem.leaveStatus),
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      );
    }

    return Material(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (leaveListItem.userName != null)
                        Text(
                          '${leaveListItem.fullName ?? ''} (${leaveListItem.userName ?? ''})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                          ),
                        ),
                      SizedBox(height: 6.h),
                      RichText(
                        text: TextSpan(
                          text: '${leaveListItem.leaveType ?? ''} · ',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: bloc.getColorFromLeaveType(
                                leaveListItem.leaveType ?? ''),
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${leaveListItem.fromDate.toStringFormat('dd MMM yyyy')} → ${leaveListItem.toDate.toStringFormat('dd MMM yyyy')}',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: cs.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        leaveListItem.dayType,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (leaveListItem.reason != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          leaveListItem.reason!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                statusControl(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResponseOptions(BuildContext context, LeaveBloc bloc) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Leave response',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline_rounded,
                      color: Color(0xFF2E7D32)),
                  title: const Text('Approve'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (leaveListItem.leaveRequestId != null) {
                      bloc.add(RespondToLeaveEvent(
                        true,
                        leaveListItem.leaveRequestId!,
                      ));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel_outlined, color: theme.colorScheme.error),
                  title: const Text('Reject'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (leaveListItem.leaveRequestId != null) {
                      bloc.add(RespondToLeaveEvent(
                        false,
                        leaveListItem.leaveRequestId!,
                      ));
                    }
                  },
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
