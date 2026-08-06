import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:i_densfa/module/attendance_module/view/apply_attendance_view.dart';
import 'package:i_densfa/module/attendance_module/view/attendance_request_view.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:upgrader/upgrader.dart';
import 'attendance_repository.dart';
import 'bloc/attendance_bloc.dart';
import 'model/attendance_model.dart';

/// Matches legacy visibility rules for In/Out columns (ExxonMobil variants).
bool _showMarkInOutColumns() {
  final c = AppStorage().userDetail?.companyName.toLowerCase() ?? '';
  return c != 'exxonmobil' ||
      c != 'exxonmobil mobile miles plant'.toLowerCase();
}

class AttendanceView extends StatelessWidget {
  final int? forUserId;
  final String name;
  const AttendanceView({super.key, required this.name, this.forUserId});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: RepositoryProvider(
        create: (context) => AttendanceRepository(forUserId),
        child: BlocProvider(
          create: (context) =>
              AttendanceBloc(context.read())
              ..add(GetAttendanceEvent())
              ..add(GetLeaveList()),
          child: BlocConsumer<AttendanceBloc, AttendanceState>(
            listenWhen: (previous, current) => current is AttendanceShowSnack,
            listener: (context, state) {
              if (state is AttendanceShowSnack) {
                context.showSnackBarMessage(state.message);
              }
            },
            buildWhen: (previous, current) => current is! AttendanceShowSnack,
            builder: (context, state) {
              final bloc = context.read<AttendanceBloc>();
              return Scaffold(
                  appBar: AppBar(
                    title: Text(name),
                    elevation: 0,
                  ),
                  floatingActionButton: AppStorage()
                              .userDetail
                              ?.configuration
                              .requiredBulkAttendance ==
                          true
                      ? _floatingButton(context, bloc)
                      : null,
                  body: state is AttendanceLoadingState
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: () async {
                          bloc.add(GetAttendanceEvent());
                        bloc.add(GetLeaveList());},
                        child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    12.w, 10.h, 12.w, 6.h),
                                child: Material(
                                  elevation: 0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.h, horizontal: 8.w),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _DateRangeChip(
                                            label: 'From',
                                            dateText: bloc.selectedOne
                                                .toStringFormat('dd MMM yyyy'),
                                            onTap: () async {
                                              final now = DateTime.now();
                                              final date = await showDatePicker(
                                                  helpText: 'Select from date',
                                                  context: context,
                                                  initialDate: now,
                                                  firstDate: DateTime(
                                                      now.year - 1,
                                                      now.month,
                                                      now.day),
                                                  lastDate: DateTime.now());
                                              if (date != null &&
                                                  context.mounted) {
                                                context
                                                    .read<AttendanceBloc>()
                                                    .add(MyActivityChangeMonth(
                                                        date,
                                                        bloc.selectedSecond));
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6.w),
                                          child: Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18.sp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        Expanded(
                                          child: _DateRangeChip(
                                            label: 'To',
                                            dateText: bloc.selectedSecond
                                                .toStringFormat('dd MMM yyyy'),
                                            onTap: () async {
                                              final now = bloc.selectedOne;
                                              final date = await showDatePicker(
                                                  helpText: 'Select to date',
                                                  context: context,
                                                  initialDate: now,
                                                  firstDate: DateTime(now.year,
                                                      now.month, now.day),
                                                  lastDate: DateTime.now());
                                              if (date != null &&
                                                  context.mounted) {
                                                context
                                                    .read<AttendanceBloc>()
                                                    .add(MyActivityChangeMonth(
                                                        bloc.selectedOne,
                                                        date));
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 4.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.h, horizontal: 6.w),
                                  child: Row(
                                    children: [
                                      const RowCellAttendance(
                                        text: 'Date',
                                        isHeader: true,
                                      ),
                                      const RowCellAttendance(
                                        isHeader: true,
                                        text: 'Start\nDuty',
                                      ),
                                      const RowCellAttendance(
                                        isHeader: true,
                                        text: 'End\nDuty',
                                      ),
                                      if (_showMarkInOutColumns())
                                        const RowCellAttendance(
                                          isHeader: true,
                                          text: 'In',
                                        ),
                                      if (_showMarkInOutColumns())
                                        const RowCellAttendance(
                                          isHeader: true,
                                          text: 'Out',
                                        ),
                                      const RowCellAttendance(
                                        isHeader: true,
                                        text: 'Span\n(Hrs)',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              bloc.attandenceData.isEmpty
                                  ? Expanded(
                                      child: _AttendanceEmptyState(
                                        onRetry: () =>
                                            bloc.add(GetAttendanceEvent()),
                                      ),
                                    )
                                  : Expanded(
                                      child: SingleChildScrollView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        child: Column(
                                          children: [
                                            AnimationLimiter(
                                              child: ListView.separated(
                                                  itemCount: bloc
                                                      .attandenceData.length,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          SizedBox(height: 6.h),
                                                  itemBuilder:
                                                      (context, index) =>
                                                          AnimationConfiguration
                                                              .staggeredList(
                                                        position: index,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    450),
                                                        child: SlideAnimation(
                                                          verticalOffset: 40.0,
                                                          child:
                                                              FadeInAnimation(
                                                            child:
                                                                AttendanceItemView(
                                                              index,
                                                              bloc.attandenceData[
                                                                  index],
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                            ),
                                            SizedBox(height: 0.08.sh),
                                          ],
                                        ),
                                      ),
                                    )
                            ],
                          ),
                      ));
            },
          ),
        ),
      ),
    );
  }

  Widget _floatingButton(BuildContext context, AttendanceBloc bloc) {
    return SpeedDial(
      closedForegroundColor: Colors.white,
      closedBackgroundColor: Theme.of(context).primaryColor,
      openForegroundColor: Theme.of(context).primaryColor,
      openBackgroundColor: Colors.white,
      speedDialChildren: _getchild(context, bloc),
      child: Icon(
        Icons.add_rounded,
        size: 28.sp,
        color: Colors.white,
      ),
    );
  }

  List<SpeedDialChild> _getchild(BuildContext context, AttendanceBloc bloc) {
    List<SpeedDialChild> option = [];
    option.add(SpeedDialChild(
      child: const Icon(Icons.checklist),
      foregroundColor: Colors.white,
      backgroundColor: Theme.of(context).primaryColor,
      label: AppStorage().userDetail?.companyName.toLowerCase() == "contractor"
          ? 'Log Activity'
          : "Apply Attendance",
      onPressed: () {
        AppPopup.showAppBottomSheet(
          context: context,
          child: BlocProvider.value(
            value: bloc,
            child: const ApplyAttendanceView(),
          ),
        );
      },
    ));

  if (AppStorage().userDetail?.role.toLowerCase() != 'fwp') {
      option.add(SpeedDialChild(
        child: const Icon(Icons.content_paste_go_sharp),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        label:
            AppStorage().userDetail?.companyName.toLowerCase() == "contractor"
                ? 'Activity Requests'
                : "Attendance Requests",
        onPressed: () {
          bloc.attendanceRequest.clear();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (c) => BlocProvider.value(
                  value: bloc..add(GetAllRequestEvent()),
                  child: const AttendanceRequestView())));
        },
      ));
    }
    return option;
  }
}

class AttendanceItemView extends StatelessWidget {
  final int index;
  final AttandanceDataNew attandenceData;

  const AttendanceItemView(this.index, this.attandenceData, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    Color cellColor(String dutyTime) {
      if (dutyTime.contains(':')) return cs.onSurface;
      if (dutyTime == 'A') return cs.error;
      return const Color(0xFF2E7D32);
    }

    final start = attandenceData.startDutyTime;
    final c = cellColor(start);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Material(
        elevation: 0,
        color: index.isEven
            ? cs.surface
            : cs.surfaceContainerHighest.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RowCellAttendance(
                text: attandenceData.date.toStringFormat('dd MMM'),
                textColor: c,
              ),
              RowCellAttendance(
                text: start.contains(',')
                    ? start.replaceAll(',', '\n')
                    : start,
                textColor: c,
              ),
              RowCellAttendance(
                text: attandenceData.endDutyTime.contains(',')
                    ? attandenceData.endDutyTime.replaceAll(',', '\n')
                    : attandenceData.endDutyTime,
                textColor: c,
              ),
              if (_showMarkInOutColumns())
                RowCellAttendance(
                  text: attandenceData.firstMarkInTime.contains(',')
                      ? attandenceData.firstMarkInTime.replaceAll(',', '\n')
                      : attandenceData.firstMarkInTime,
                  textColor: c,
                ),
              if (_showMarkInOutColumns())
                RowCellAttendance(
                  text: attandenceData.lastMarkOutTime.contains(',')
                      ? attandenceData.lastMarkOutTime.replaceAll(',', '\n')
                      : attandenceData.lastMarkOutTime,
                  textColor: c,
                ),
              RowCellAttendance(
                text: attandenceData.spanInhr.contains(',')
                    ? attandenceData.spanInhr.replaceAll(',', '\n')
                    : attandenceData.spanInhr,
                textColor: c,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RowCellAttendance extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool isBold;
  final bool isHeader;

  const RowCellAttendance({
    super.key,
    required this.text,
    this.textColor = Colors.black,
    this.isBold = false,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = isHeader
        ? theme.colorScheme.onSurface
        : textColor;
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader || isBold
                ? FontWeight.w700
                : FontWeight.w500,
            fontSize: isHeader ? 11.sp : 10.sp,
            height: 1.25,
            letterSpacing: isHeader ? 0.2 : 0,
            color: effectiveColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  final String label;
  final String dateText;
  final VoidCallback onTap;

  const _DateRangeChip({
    required this.label,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16.sp,
                color: theme.primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceEmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _AttendanceEmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 0.12.sh),
        Icon(
          Icons.event_note_rounded,
          size: 56.sp,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
        ),
        SizedBox(height: 16.h),
        Text(
          'No records for this range',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            'Try another date range or pull to refresh. If data should appear, you can retry loading.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Center(
          child: FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
