import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/analytics_module/analytics_view.dart';
import 'package:i_densfa/module/my_schedule_module/my_schedule_view.dart';
import 'package:i_densfa/module/team_module/models/team_list_model.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TeamProfileView extends StatelessWidget {
  final TeamMemberModel memberDetail;
  const TeamProfileView({super.key, required this.memberDetail});

  @override
  Widget build(BuildContext context) {
    final bottomCardItems = <BottomCardItemModel>[
      BottomCardItemModel('Scorecard', const Icon(Icons.analytics), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) {
            return AnalyticsView(forUserId: memberDetail.userId);
          }),
        );
      }),
      BottomCardItemModel('Activity History', const Icon(Icons.score), () {
        context.push(
          AppPaths.myActivity,
          extra: memberDetail.userId,
        );
      }),
      BottomCardItemModel('Attendance', const Icon(Icons.person_4), () {
        context.push(AppPaths.attendance, extra: memberDetail.userId);
      }),
      BottomCardItemModel('Schedule', const Icon(Icons.schedule), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) {
            return MyScheduleView(forUserId: memberDetail.userId);
          }),
        );
      }),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        backgroundColor: Colors.grey.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shadowColor: ColorConstants.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w),
                  side: const BorderSide(
                    color: ColorConstants.amber,
                    width: 1.5,
                  )),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      position: DecorationPosition.foreground,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: ColorConstants.amberFade, width: 3)),
                      child: CircleAvatar(
                          radius: 35,
                          backgroundImage: CachedNetworkImageProvider(
                              memberDetail.photoUrl ?? '')),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      memberDetail.username,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Role:${memberDetail.role}',
                      style: TextStyle(
                          fontSize: 11.sp, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      'Designation:${memberDetail.designation}',
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green),
                        Text(
                          'Active Today',
                          style: TextStyle(fontSize: 10.sp),
                        )
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        RoundedBorderedIconButton(
                          icon: Icons.call_sharp,
                          onPressed: () {
                            launchUrlString('tel://+91${memberDetail.mobile}');
                          },
                        ),
                        SizedBox(width: 20.w),
                        RoundedBorderedIconButton(
                          icon: Icons.mail,
                          onPressed: () {
                            launchUrlString('mailto:${memberDetail.email}');
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              shadowColor: ColorConstants.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w),
                  side: const BorderSide(
                    color: ColorConstants.amber,
                    width: 1.5,
                  )),
              child: Column(
                children: List.generate(bottomCardItems.length,
                    (index) => bottomCardItemView(bottomCardItems[index])),
              ),
            )
          ],
        ),
      ),
    );
  }

  ListTile bottomCardItemView(BottomCardItemModel item) {
    return ListTile(
      leading: item.leading,
      title: Text(
        item.title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      onTap: item.onTap,
    );
  }
}

class BottomCardItemModel {
  final String title;
  final Widget leading;
  final VoidCallback onTap;

  BottomCardItemModel(this.title, this.leading, this.onTap);
}

class RoundedBorderedIconButton extends StatelessWidget {
  final IconData icon;
  final void Function()? onPressed;
  const RoundedBorderedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ColorConstants.amber),
      ),
      child: IconButton(
        iconSize: 30,
        icon: Icon(
          icon,
          color: ColorConstants.amber,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
