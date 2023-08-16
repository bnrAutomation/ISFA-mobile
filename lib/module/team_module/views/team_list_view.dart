import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/team_module/bloc/team_bloc.dart';
import 'package:i_densfa/utility/app_constants.dart';

class TeamListView extends StatefulWidget {
  const TeamListView({super.key});

  @override
  State<TeamListView> createState() => _TeamListViewState();
}

class _TeamListViewState extends State<TeamListView> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final TeamBloc teamBloc = context.watch();
    return Container(
      margin: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ]),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _teamDataCardView(context),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SearchBar(
                  hintText: 'Search by Name or Email',
                  side: MaterialStateProperty.all(
                      const BorderSide(width: 1.0, color: Colors.grey)),
                  controller: searchController,
                  elevation: MaterialStateProperty.all(0.0),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  onChanged: (value) => teamBloc.add(SearchTeamEvent(value))),
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: teamBloc.myTeamMembersFiltered.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final memberDetail = teamBloc.myTeamMembersFiltered[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 35),
                      SizedBox(width: 5.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberDetail.username,
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Designation:${memberDetail.designation}',
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'Role:${memberDetail.role}',
                            style: TextStyle(
                                fontSize: 11.sp, fontWeight: FontWeight.w300),
                          ),
                          ColoredBox(
                              color: ColorConstants.amberFade,
                              child: Text(
                                memberDetail.mobile,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.normal),
                              )),
                        ],
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _teamDataCardView(BuildContext context) {
    final data = context.read<TeamBloc>().teamData;
    if (data == null) {
      return const SizedBox();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.activeToday.toString(),
                style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp),
              ),
              SizedBox(width: 10.w),
              const Text("Active or Logged Today"),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.w),
                child: LinearProgressIndicator(
                    backgroundColor: const Color(0xfffff3cd),
                    color: ColorConstants.amber,
                    minHeight: 40,
                    value: data.activeToday / data.totalMembersAdded),
              ),
              SizedBox(height: 15.h),
              Text(
                data.totalMembersAdded.toString(),
                style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp),
              ),
              SizedBox(width: 10.w),
              const Text("Total Members Added"),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.w),
                child: const LinearProgressIndicator(
                    backgroundColor: Color(0xfffff3cd),
                    color: ColorConstants.amber,
                    minHeight: 40,
                    value: 1),
              ),
              SizedBox(height: 15.h),
              Text(
                data.noRecentLogin.toString(),
                style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp),
              ),
              SizedBox(width: 10.w),
              const Text("No Recent Login"),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.w),
                child: LinearProgressIndicator(
                    backgroundColor: const Color(0xfffff3cd),
                    color: ColorConstants.amber,
                    minHeight: 40,
                    value: data.noRecentLogin / data.totalMembersAdded),
              ),
              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),
    );
  }
}
