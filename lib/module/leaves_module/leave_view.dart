import 'package:circular_progress_bar_with_lines/circular_progress_bar_with_lines.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/leaves_module/leave/leave_bloc.dart';
import 'package:i_densfa/module/leaves_module/model/leave_model.dart';
import 'package:i_densfa/module/ui/custom_material_button.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_pop_view.dart';
import 'package:intl/intl.dart';

import '../ui/app_tabview_view.dart';
import 'leave_repository.dart';

class LeaveView extends StatelessWidget {
  LeaveView({super.key});
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "My Leave",
          style: textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
      ),
      body: RepositoryProvider(
        create: (context) => LeaveRepository(),
        child: BlocProvider(
          create: (context) =>
              LeaveBloc(context.read())..add(GetLeaveDetailsEvent()),
          child: BlocBuilder<LeaveBloc, LeaveState>(
            builder: (context, state) {
              if (state is LeaveViewLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final bloc = context.read<LeaveBloc>();
              if (bloc.details == null) {
                return Center(
                  child: TextButton(
                    child: const Text("Retry"),
                    onPressed: () => bloc.add(GetLeaveDetailsEvent()),
                  ),
                );
              }
              return SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                        delegate: SliverChildListDelegate.fixed([
                      const SizedBox(height: 5),
                      leaveBalanceCard(context, bloc, textTheme),
                      const SizedBox(height: 4),
                      Container(
                        constraints:
                            BoxConstraints(minWidth: 1.sw, maxHeight: 130),
                        padding: const EdgeInsets.all(2.0),
                        child: ListView.builder(
                          itemCount: bloc.details!.leaveTypeBalance.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) =>
                              _leaveTypeBalance(context, index),
                        ),
                      ),
                    ])),
                    SliverFillRemaining(
                        child: AppTabViewController(
                      backgroundColor: Colors.transparent,
                      titles: const ['Applied Leave', 'Requested Leave'],
                      children: [
                        Builder(
                          builder: (context) {
                            final leaveList =
                                bloc.details?.empAppliedLeave ?? [];
                            return ListView.separated(
                                itemCount: leaveList.length,
                                padding: const EdgeInsets.all(5),
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                      height: 5,
                                      thickness: 1.0,
                                      color: Colors.black12,
                                    ),
                                itemBuilder: (c, index) =>
                                    ApproveLeave(leaveList[index]));
                          },
                        ),
                        Builder(
                          builder: (context) {
                            final leaveList =
                                bloc.details?.reporteeRequestedLeave ?? [];
                            return ListView.separated(
                                itemCount: leaveList.length,
                                padding: const EdgeInsets.all(5),
                                separatorBuilder: (c, index) => const Divider(
                                      height: 5,
                                      thickness: 1.0,
                                      color: Colors.black12,
                                    ),
                                itemBuilder: (context, index) =>
                                    ApproveLeave(leaveList[index]));
                          },
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Card leaveBalanceCard(
      BuildContext context, LeaveBloc bloc, TextTheme textTheme) {
    return Card(
      color: const Color(0XFFBFD1DF),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4),
            InkWell(
              onTap: () {
                AppPopup.showAppBottomSheet(
                  context: context,
                  child: BlocProvider.value(
                    value: bloc,
                    child: _openSheet(context),
                  ),
                );
              },
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      RotationTransition(
                        turns: AlwaysStoppedAnimation(
                            bloc.details!.usedLeave / bloc.details!.totalLeave),
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
                        linesColor: Theme.of(context).colorScheme.primary,
                        centerWidgetBuilder: (context) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bloc.details!.leaveBalance.toString(),
                              style: textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Leave Balance",
                              style: textTheme.bodyMedium,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Click to apply for leave",
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "⚫ Total Leave",
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      bloc.details!.totalLeave.toString(),
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "⚫ Used Leave",
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      bloc.details!.usedLeave.toString(),
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _leaveTypeBalance(BuildContext context, int index) {
    final textTheme = Theme.of(context).textTheme;
    final model = context.read<LeaveBloc>().details!.leaveTypeBalance[index];

    final ccolor = index == 0
        ? Theme.of(context).colorScheme.primary
        : index == 1
            ? const Color(0XFFC92434)
            : index == 2
                ? Colors.amber
                : Colors.black;
    final bloc = context.read<LeaveBloc>();
    return Card(
      color: ccolor,
      child: Stack(
        children: [
          SvgPicture.asset(ImageConstants.leavemask, fit: BoxFit.fill),
          Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                child: SvgPicture.asset(bloc.getLeaveTypeBalanceIcon(index)),
              )),
          Positioned(
              left: 4,
              bottom: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.leaveTypeBalance.toString(),
                    style: textTheme.headlineLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
    );
  }

  Widget _openSheet(BuildContext context) {
    return Builder(builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      final bloc = context.read<LeaveBloc>();
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
              width: 1.sw,
            ),
            Text(
              "Apply for leave",
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Leave Type", style: textTheme.labelLarge),
            const SizedBox(height: 5),
            LeaveDropDownOptions(
              options: LeaveType.values.map((e) => "${e.name} Leave").toList(),
              hint: "Please select leave type",
              selectedVal:
                  context.select((LeaveBloc value) => value.selectLeaveType),
              valChanged: (value) {
                if (value != null) {
                  bloc.add(ChangeLeaveTypeEvent(value));
                }
              },
            ),
            const SizedBox(height: 10),
            Text("Day part", style: textTheme.labelLarge),
            const SizedBox(height: 5),
            SizedBox(
              width: 1.sw,
              child: CupertinoSlidingSegmentedControl(
                  padding: const EdgeInsets.all(0),
                  thumbColor: Theme.of(context).colorScheme.background,
                  groupValue: context
                      .select((LeaveBloc value) => value.selectedLeaveDayPart),
                  children: {
                    for (var partName in bloc.leaveDayParts)
                      partName: Center(child: Text(partName))
                  },
                  onValueChanged: (val) {
                    if (val != null) {
                      bloc.add(ChangeLeaveDayPartEvent(val));
                    }
                  }),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("From", style: textTheme.labelLarge),
                      const SizedBox(height: 5),
                      Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: BlocListener<LeaveBloc, LeaveState>(
                          listener: (context, state) {
                            final fromDate = bloc.fromDate;
                            if (fromDate != null) {
                              fromDateController.text = DateFormat()
                                  .addPattern("dd/MM/yyyy")
                                  .format(fromDate);
                            }
                          },
                          child: TextFormField(
                            controller: fromDateController,
                            decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_month_outlined),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 8, bottom: 11, top: 11, right: 8),
                                hintText: "DD/MM/YYYY"),
                            readOnly: true,
                            onTap: () async {
                              final now = DateTime.now();
                              final date = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: now,
                                  lastDate: DateTime(now.year, 12, 31));
                              if (date != null && context.mounted) {
                                context
                                    .read<LeaveBloc>()
                                    .add(FromDateLeaveTypeEvent(date));
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("To", style: textTheme.labelLarge),
                      const SizedBox(height: 5),
                      Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: BlocListener<LeaveBloc, LeaveState>(
                          listener: (context, state) {
                            final fromDate = bloc.toDate;
                            if (fromDate != null) {
                              toDateController.text = DateFormat()
                                  .addPattern("dd/MM/yyyy")
                                  .format(fromDate);
                            }
                          },
                          child: TextFormField(
                            controller: toDateController,
                            decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.calendar_month_outlined),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 8, bottom: 11, top: 11, right: 8),
                                hintText: "DD/MM/YYYY"),
                            readOnly: true,
                            onTap: () async {
                              final now = DateTime.now();
                              final date = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: now,
                                lastDate: DateTime(now.year, 12, 31),
                              );
                              if (date != null && context.mounted) {
                                context
                                    .read<LeaveBloc>()
                                    .add(ToDateLeaveTypeEvent(date));
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text("Reason", style: textTheme.labelLarge),
            const SizedBox(height: 5),
            Container(
              width: 1.sw,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.only(left: 8, bottom: 8, top: 8, right: 8),
                    hintText: "Type your reason here..."),
                minLines: 2,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 10),
            CustomMaterialButton(
                buttonText: "Submit for Approve",
                onPressed: () => context.pop()),
            const SizedBox(height: 10),
          ],
        ),
      );
    });
  }
}

class LeaveDropDownOptions extends StatelessWidget {
  final List<String> options;
  final String hint;
  final void Function(String?)? valChanged;
  final String? selectedVal;
  const LeaveDropDownOptions({
    super.key,
    required this.options,
    required this.hint,
    required this.valChanged,
    this.selectedVal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
        value: selectedVal,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: valChanged,
        hint: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            hint,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      )),
    );
  }
}

class ApproveLeave extends StatelessWidget {
  final AppliedLeaveModel leaveList;

  const ApproveLeave(this.leaveList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leaveList.userName != null)
                  Text(leaveList.userName!,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(Icons.circle,
                          size: 12, color: leaveList.leaveType?.refColor),
                    ),
                    Expanded(
                      child: RichText(
                          text: TextSpan(
                              text: "${leaveList.leaveType?.toStr()}",
                              style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: leaveList.leaveType?.refColor,
                                  fontWeight: FontWeight.bold),
                              children: [
                            TextSpan(
                              text:
                                  ' Applied from ${DateFormat('dd MMM yyyy').format(leaveList.fromDate)} to ${DateFormat('dd MMM yyyy').format(leaveList.toDate)}',
                              style: GoogleFonts.inter(
                                  fontSize: 11.sp, color: Colors.black),
                            )
                          ])),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: leaveList.leaveStatus == LeaveStatus.approve
                    ? Colors.green
                    : leaveList.leaveStatus == LeaveStatus.reject
                        ? Colors.red
                        : Colors.amber),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            margin: const EdgeInsets.only(left: 5),
            child: Text(
              leaveList.leaveStatus.toStr().toUpperCase(),
              style: TextStyle(
                  color: leaveList.leaveStatus == LeaveStatus.request
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
