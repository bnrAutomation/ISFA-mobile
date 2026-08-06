import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/notification/notifcation_model.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'bloc/notification_bloc.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  static const Color _surface = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorConstants.amber,
        foregroundColor: Colors.black,
        toolbarHeight: 48.h,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          iconSize: 20.sp,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocProvider(
        lazy: false,
        create: (context) => NotificationBloc(),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            }
            final bloc = context.read<NotificationBloc>();
            final notifications = bloc.notifcations;

            if (notifications.isEmpty) {
              return _NotificationsEmpty(bloc: bloc);
            }

            return RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () async {
                bloc.add(GetNotificationsEvent());
                await bloc.stream.firstWhere((s) => s is NotificationsReady);
              },
              child: AnimationLimiter(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 12.h),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => SizedBox(height: 6.h),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 320),
                      child: SlideAnimation(
                        verticalOffset: 16,
                        child: FadeInAnimation(
                          child: _NotificationListTile(
                            model: item,
                            onTap: () => _onTileTap(context, item),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onTileTap(BuildContext context, NotificationModel n) {
    if (n.notificationType == 'ticket' &&
        (n.notedata?.ticketId.isNotEmpty ?? false)) {
      context.pushNamed(
        AppPaths.issuesDetail,
        extra: n.notedata!.ticketId,
      );
    }
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty({required this.bloc});

  final NotificationBloc bloc;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(GetNotificationsEvent());
        await bloc.stream.firstWhere((s) => s is NotificationsReady);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 40.h),
          Icon(
            Icons.notifications_none_rounded,
            size: 48.sp,
            color: Colors.black26,
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              'No notifications yet',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'When you receive updates, they will appear here. Pull to refresh.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.black54,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  const _NotificationListTile({
    required this.model,
    required this.onTap,
  });

  final NotificationModel model;
  final VoidCallback onTap;

  bool get _isTappable =>
      model.notificationType == 'ticket' &&
      (model.notedata?.ticketId.isNotEmpty ?? false);

  IconData _iconForType() {
    switch (model.notificationType.toLowerCase()) {
      case 'ticket':
        return Icons.confirmation_number_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: _isTappable ? onTap : null,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: ColorConstants.amber.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _iconForType(),
                  color: Colors.black87,
                  size: 17.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.title.isEmpty ? 'Notification' : model.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      model.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 11.sp,
                          color: Colors.black45,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            model.createdDate
                                .toStringFormat('dd MMM yyyy, hh:mm a'),
                            style: GoogleFonts.poppins(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                        if (model.createdBy.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              model.createdBy,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5.sp,
                                color: Colors.black38,
                              ),
                            ),
                          ),
                        ],
                        if (_isTappable) ...[
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16.sp,
                            color: Colors.black38,
                          ),
                        ],
                      ],
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
