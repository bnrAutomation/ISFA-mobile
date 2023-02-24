import 'package:circular_progress_bar_with_lines/circular_progress_bar_with_lines.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_densfa/module/leaves_module/model/leave_model.dart';
import 'package:i_densfa/module/ui/app_tabview_view.dart';
import 'package:i_densfa/utility/app_constants.dart';

class LeaveView extends StatelessWidget {
  LeaveView({super.key});

  final List<LeavesData> leaveList = [
    LeavesData(
      statusConstants.casualTypeLeave,
      "28 Jan 2023",
      "30 Jan 2023",
      statusConstants.requestLeave,
    ), //requested
    LeavesData(
      statusConstants.sickTypeLeave,
      "28 Jan 2023",
      "30 Jan 2023",
      statusConstants.approveLeave,
    ), //approved
    LeavesData(
      statusConstants.weekOffTypeLeave,
      "28 Jan 2023",
      "30 Jan 2023",
      statusConstants.rejectLeave,
    ), //rejected
    LeavesData(
      statusConstants.otherTypeLeave,
      "28 Jan 2023",
      "30 Jan 2023",
      statusConstants.rejectLeave,
    ), //rejected
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0XFF003D5B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "My Leave",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: const Color(0XFFBFD1DF),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                //set border radius more than 50% of height and width to make circle
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Align(
                    //   alignment: Alignment.topRight,
                    //   child: Text(
                    //     "Upcomming Leave",
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .bodySmall
                    //         ?.copyWith(color: Colors.red),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 4,
                    ),
                    InkWell(
                      onTap: () => {},
                      child: CircularProgressBarWithLines(
                        radius: 56,
                        percent: 80,
                        linesAmount: 80,
                        linesLength: 20,
                        linesColor: Theme.of(context).colorScheme.primary,
                        centerWidgetBuilder: (context) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "12",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Leave Balance",
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Click to apply for leave",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "⚫ Total Leave",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              "20",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          //  crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "⚫ Used Leave",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              "8",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Container(
              constraints: BoxConstraints(minWidth: 1.sw, maxHeight: 130),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => widgetList(context)[index],
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: AppTabViewController(
                backgroundColor: Colors.transparent,
                titles: const ['Approved', 'Informed'],
                children: [
                  ListView.separated(
                      itemCount: leaveList.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(5),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 5),
                      itemBuilder: (context, index) =>
                          ApproveLeave(leaveList[index])),
                  ListView.separated(
                      itemCount: leaveList.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(5),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 5),
                      itemBuilder: (context, index) =>
                          ApproveLeave(leaveList[index])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> widgetList(BuildContext context) {
    return [
      Card(
        color: Theme.of(context).colorScheme.primary,
        child: Stack(
          children: [
            SvgPicture.asset(
              imageConstants.leavemask,
              fit: BoxFit.fill,
            ),
            Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      imageConstants.doorOut,
                    ),
                  ),
                )),
            Positioned(
                left: 4,
                bottom: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "8",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Casual Leave",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(
                      height: 5,
                    )
                  ],
                ))
          ],
        ),
      ),
      Card(
        color: const Color(0XFFC92434),
        child: Stack(
          children: [
            SvgPicture.asset(
              imageConstants.leavemask,
              fit: BoxFit.fill,
            ),
            Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      imageConstants.sick,
                    ),
                  ),
                )),
            Positioned(
                left: 4,
                bottom: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "5",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Sick Leave",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(
                      height: 5,
                    )
                  ],
                ))
          ],
        ),
      ),
      Card(
        color: Colors.amber,
        child: Stack(
          children: [
            SvgPicture.asset(
              imageConstants.leavemask,
              fit: BoxFit.fill,
            ),
            Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      imageConstants.walkman,
                    ),
                  ),
                )),
            Positioned(
                left: 4,
                bottom: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "7",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Week Off",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(
                      height: 5,
                    )
                  ],
                ))
          ],
        ),
      ),
      Card(
        color: Colors.black,
        child: Stack(
          children: [
            SvgPicture.asset(
              imageConstants.leavemask,
              fit: BoxFit.fill,
            ),
            Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      imageConstants.sunumbrella,
                    ),
                  ),
                )),
            Positioned(
                left: 4,
                bottom: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "3",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Others",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(
                      height: 5,
                    )
                  ],
                ))
          ],
        ),
      ),
    ];
  }
}

class ApproveLeave extends StatelessWidget {
  final LeavesData leaveList;

  const ApproveLeave(this.leaveList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      //color: Mycolor.myLeaveBodyBg,
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(3, 7, 3, 7),
                        child: Icon(Icons.circle,
                            size: 12,
                            color: leaveList.leaveType ==
                                    statusConstants.casualTypeLeave
                                ? Colors.green
                                : leaveList.leaveType ==
                                        statusConstants.sickTypeLeave
                                    ? Colors.red
                                    : (leaveList.leaveType ==
                                            statusConstants.weekOffTypeLeave)
                                        ? Colors.amber
                                        : Colors.black),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: Text(
                          leaveList.leaveType == statusConstants.casualTypeLeave
                              ? "Casual Leave"
                              : leaveList.leaveType ==
                                      statusConstants.sickTypeLeave
                                  ? "Sick Leave"
                                  : (leaveList.leaveType ==
                                          statusConstants.weekOffTypeLeave)
                                      ? "WeekOff Leave"
                                      : "Other",
                          style: TextStyle(
                              color: leaveList.leaveType ==
                                      statusConstants.casualTypeLeave
                                  ? Colors.green
                                  : leaveList.leaveType ==
                                          statusConstants.sickTypeLeave
                                      ? Colors.red
                                      : (leaveList.leaveType ==
                                              statusConstants.weekOffTypeLeave)
                                          ? Colors.amber
                                          : Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        leaveList.fromLeave,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(25, 3, 10, 3),
                    child: Text(
                      leaveList.toLeave,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                decoration: leaveList.approvalStatus ==
                        statusConstants.rejectLeave
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: const Color(0x34000000), width: 2),
                      )
                    : leaveList.approvalStatus == statusConstants.approveLeave
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.green)
                        : (leaveList.approvalStatus ==
                                statusConstants.rejectLeave)
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.red)
                            : const BoxDecoration(),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                margin: const EdgeInsets.only(right: 10),
                child: Text(
                  leaveList.approvalStatus == statusConstants.requestLeave
                      ? "Requested"
                      : leaveList.approvalStatus == statusConstants.approveLeave
                          ? "Approved"
                          : (leaveList.approvalStatus ==
                                  statusConstants.rejectLeave)
                              ? "Rejected"
                              : "",
                  style: TextStyle(
                      color: leaveList.approvalStatus ==
                              statusConstants.requestLeave
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const Divider(
            height: 5,
            thickness: 1.0,
            color: Colors.black12,
          )
        ],
      ),
    );
  }
}
