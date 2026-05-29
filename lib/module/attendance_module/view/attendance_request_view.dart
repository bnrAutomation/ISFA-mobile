import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/attendance_module/bloc/attendance_bloc.dart';
import 'package:i_densfa/module/attendance_module/model/attendance_request_model.dart';
import 'package:i_densfa/module/ui/dialog_view.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/mat_month_picker_dialog.dart';

class AttendanceRequestView extends StatelessWidget {
  const AttendanceRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final title = AppStorage().userDetail?.companyName.toLowerCase() ==
            "contractor"
        ? 'Activity Requests'
        : 'Attendance Requests';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<AttendanceBloc, AttendanceState>(
          listener: (BuildContext context, AttendanceState state) {},
          builder: (BuildContext context, AttendanceState state) {
            final bloc = context.read<AttendanceBloc>();
            final theme = Theme.of(context);
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Material(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 4.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 12.w),
                              child: Text(
                                bloc.requestSelected
                                    .toStringFormat('MMMM yyyy'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () async {
                              final now = DateTime.now();
                              final date = await showMonthPicker(
                                context: context,
                                initialDate: now,
                                firstDate: DateTime(now.year - 1, now.month),
                                lastDate: DateTime(now.year + 1),
                              );
                              if (date != null && context.mounted) {
                                bloc.add(RequestChangeMonth(date));
                              }
                            },
                            icon: Icon(Icons.calendar_month_rounded,
                                color: theme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Material(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 22.sp,
                            color: theme.primaryColor,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Long-press a request to enable bulk approve or reject. Then use the actions at the bottom.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.35,
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (bloc.islongPress)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      child: CheckboxListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 4.w),
                        dense: true,
                        value: bloc.isallCheck,
                        onChanged: (val) {
                          bloc.add(AllCheckRequest(val ?? false));
                        },
                        title: Text(
                          'Select all pending',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ),
                Expanded(
                  child: state is AttendanceLoadingState
                      ? const Center(child: CircularProgressIndicator())
                      : bloc.attendanceRequest.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 0.1.sh),
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 56.sp,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.45),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'No requests this month',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 40.w),
                                  child: Text(
                                    'Change the month above or check back later.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : AnimationLimiter(
                              child: ListView.separated(
                                controller: bloc.scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: bloc.attendanceRequest.length,
                                padding: EdgeInsets.fromLTRB(
                                    12.w, 8.h, 12.w, 16.h),
                                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                                itemBuilder: (c, index) =>
                                    AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration:
                                      const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 40.0,
                                    child: FadeInAnimation(
                                      child: ApproveAttendance(
                                        bloc.attendanceRequest[index],
                                        bloc,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ),
                if (bloc.islongPress)
                  Material(
                    elevation: 12,
                    shadowColor: Colors.black26,
                    color: theme.colorScheme.surface,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
                        child: state is AcceptLoadingState
                            ? SizedBox(
                                height: 48.h,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E7D32),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.h),
                                      ),
                                      onPressed: () {
                                        showGeneralDialog(
                                          context: context,
                                          pageBuilder: (context, _, __) =>
                                              DialogView(
                                            title: 'Accept',
                                            description:
                                                'Do you want to accept the selected requests?',
                                            okayButtonText: 'Accept',
                                            onDelete: () async {
                                              context.pop();
                                              bloc.add(RequestResonseEvent(true));
                                            },
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.check_rounded),
                                      label: const Text('Accept'),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.error,
                                        foregroundColor:
                                            theme.colorScheme.onError,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.h),
                                      ),
                                      onPressed: () {
                                        showGeneralDialog(
                                          context: context,
                                          pageBuilder: (context, _, __) =>
                                              DialogView(
                                            title: 'Reject',
                                            description:
                                                'Do you want to reject the selected requests?',
                                            okayButtonText: 'Reject',
                                            onDelete: () async {
                                              context.pop();
                                              bloc.add(RequestResonseEvent(false));
                                            },
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                      label: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ApproveAttendance extends StatelessWidget {
  final AttendanceRequestData leaveListItem;
  final AttendanceBloc bloc;
  const ApproveAttendance(this.leaveListItem, this.bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget statusChip(String label, Color fg, Color bg) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    Widget pendingActions() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filled(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              showGeneralDialog(
                context: context,
                pageBuilder: (context, _, __) => DialogView(
                  title: 'Accept',
                  description: 'Do you want to accept this request?',
                  okayButtonText: 'Accept',
                  onDelete: () async {
                    context.pop();
                    bloc.add(SingleRequestResonseEvent(
                      leaveListItem.attendanceId,
                      true,
                    ));
                  },
                ),
              );
            },
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            icon: const Icon(Icons.check_rounded, size: 22),
          ),
          SizedBox(width: 6.w),
          IconButton.filled(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              showGeneralDialog(
                context: context,
                pageBuilder: (context, _, __) => DialogView(
                  title: 'Reject',
                  description: 'Do you want to reject this request?',
                  okayButtonText: 'Reject',
                  onDelete: () async {
                    context.pop();
                    bloc.add(SingleRequestResonseEvent(
                      leaveListItem.attendanceId,
                      false,
                    ));
                  },
                ),
              );
            },
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: cs.error,
            ),
            icon: const Icon(Icons.close_rounded, size: 22),
          ),
        ],
      );
    }

    Widget trailingContent() {
      if (bloc.islongPress) {
        if (leaveListItem.healthStatus == null) {
          return statusChip('Pending', cs.onSurfaceVariant,
              cs.surfaceContainerHighest.withValues(alpha: 0.8));
        }
        return leaveListItem.healthStatus == true
            ? statusChip(
                'Accepted', const Color(0xFF1B5E20), const Color(0xFFC8E6C9))
            : statusChip(
                'Rejected', cs.onErrorContainer, cs.errorContainer);
      }
      if (leaveListItem.healthStatus == null) {
        return pendingActions();
      }
      return leaveListItem.healthStatus == true
          ? statusChip(
              'Accepted', const Color(0xFF1B5E20), const Color(0xFFC8E6C9))
          : statusChip(
              'Rejected', cs.onErrorContainer, cs.errorContainer);
    }

    return Material(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.28)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onLongPress: () {
          bloc.islongPress = !bloc.islongPress;
          bloc.add(DateChangedEvent());
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 10.h, 10.w, 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bloc.islongPress && leaveListItem.healthStatus == null)
                Padding(
                  padding: EdgeInsets.only(right: 4.w, top: 2.h),
                  child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: leaveListItem.isSeleted,
                    onChanged: (value) {
                      leaveListItem.isSeleted = value ?? false;
                      bloc.add(DateChangedEvent());
                    },
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leaveListItem.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.15,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Regularize · ${leaveListItem.inDate.toStringFormat('dd MMM yyyy')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 16.sp, color: theme.primaryColor),
                        SizedBox(width: 6.w),
                        Text(
                          '${leaveListItem.i18nStartTime.toStringFormat('HH:mm')} – ${leaveListItem.i18nEndTime.toStringFormat('HH:mm')}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Remark',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      leaveListItem.reason.trim().isEmpty
                          ? '—'
                          : leaveListItem.reason,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4.w, top: 2.h),
                child: trailingContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
