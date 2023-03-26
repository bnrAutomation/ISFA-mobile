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
import 'model/leave_enums.dart';

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
          child: BlocConsumer<LeaveBloc, LeaveState>(
            listenWhen: (previous, current) => current is LeaveViewShowSnack,
            listener: (context, state) {
              if (state is LeaveViewShowSnack) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                ));
              }
            },
            buildWhen: (previous, current) => current is! LeaveViewShowSnack,
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
                      initialIndex: bloc.bottomTabSelectedIndex,
                      onTabTap: (p0) => bloc.bottomTabSelectedIndex = p0,
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
                    child: _leaveApplyForm(),
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

  Widget _leaveApplyForm() {
    return Scaffold(
      body: BlocConsumer<LeaveBloc, LeaveState>(
          listenWhen: (previous, current) => current is LeaveAppliedSuccess,
          listener: (context, state) => context.pop(),
          builder: (context, state) {
            final textTheme = Theme.of(context).textTheme;
            final bloc = context.read<LeaveBloc>();
            if (state is LeaveApplyLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
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
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Leave Type", style: textTheme.labelLarge),
                  const SizedBox(height: 5),
                  LeaveDropDownOptions(
                    options: bloc.leaveOptions.map((e) => e.leaveType).toList(),
                    hint: "Please select leave type",
                    selectedVal: context
                        .select((LeaveBloc value) => value.selectLeaveType),
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
                    child: CupertinoSlidingSegmentedControl<LeaveDayPart>(
                        padding: const EdgeInsets.all(0),
                        thumbColor: Theme.of(context).colorScheme.background,
                        groupValue: context.select(
                            (LeaveBloc value) => value.selectedLeaveDayPart),
                        children: {
                          for (var partName in LeaveDayPart.values)
                            partName: Center(child: Text(partName.name))
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
                                      suffixIcon:
                                          Icon(Icons.calendar_month_outlined),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          left: 8,
                                          bottom: 11,
                                          top: 11,
                                          right: 8),
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
                                      bloc.add(FromDateLeaveTypeEvent(date));
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
                                      suffixIcon:
                                          Icon(Icons.calendar_month_outlined),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                          left: 8,
                                          bottom: 11,
                                          top: 11,
                                          right: 8),
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
                                      bloc.add(ToDateLeaveTypeEvent(date));
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
                          contentPadding: EdgeInsets.only(
                              left: 8, bottom: 8, top: 8, right: 8),
                          hintText: "Type your reason here..."),
                      minLines: 2,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) => bloc.reason = value,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomMaterialButton(
                      buttonText: "Submit for Approval",
                      onPressed: () => bloc.add(ApplyNewLeave())),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }),
    );
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
  final AppliedLeaveModel leaveListItem;

  const ApproveLeave(this.leaveListItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 50.h),
      child: ListTile(
        trailing: (leaveListItem.userName != null)
            ? FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor:
                        leaveListItem.leaveStatus == LeaveStatus.approved
                            ? Colors.green
                            : leaveListItem.leaveStatus == LeaveStatus.rejected
                                ? Colors.red
                                : Colors.amber),
                onPressed: leaveListItem.leaveStatus == LeaveStatus.pending
                    ? () => _showResponseOptions(context, context.read())
                    : null,
                child: Text(
                  leaveListItem.leaveStatus.toStr().toUpperCase(),
                  style: TextStyle(
                      color: leaveListItem.leaveStatus == LeaveStatus.pending
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold),
                ))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(leaveListItem.leaveStatus.toStr().toUpperCase(),
                    style: TextStyle(
                        color: leaveListItem.leaveStatus == LeaveStatus.approved
                            ? Colors.green
                            : leaveListItem.leaveStatus == LeaveStatus.rejected
                                ? Colors.red
                                : Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
        title: leaveListItem.userName == null
            ? null
            : Text(leaveListItem.userName!,
                style: TextStyle(color: Theme.of(context).primaryColor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                text: TextSpan(
                    text: "● ${leaveListItem.leaveType}",
                    style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: context.read<LeaveBloc>().getColorFromLeaveType(
                            leaveListItem.leaveType ?? ''),
                        fontWeight: FontWeight.bold),
                    children: [
                  TextSpan(
                    text:
                        ' Applied from ${DateFormat('dd MMM yyyy').format(leaveListItem.fromDate)} to ${DateFormat('dd MMM yyyy').format(leaveListItem.toDate)}',
                    style:
                        GoogleFonts.inter(fontSize: 11.sp, color: Colors.black),
                  )
                ])),
            if (leaveListItem.reason != null) Text(leaveListItem.reason!)
          ],
        ),
      ),
    );
  }

  void _showResponseOptions(BuildContext context, LeaveBloc bloc) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text('Leave response'),
            cancelButton: TextButton(
                onPressed: () => context.pop(), child: const Text('Cancel')),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (leaveListItem.leaveRequestId != null) {
                      final event = RespondToLeaveEvent(
                          true, leaveListItem.leaveRequestId!);
                      bloc.add(event);
                    }
                  },
                  child: const Text('Approve')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (leaveListItem.leaveRequestId != null) {
                      final event = RespondToLeaveEvent(
                          false, leaveListItem.leaveRequestId!);
                      bloc.add(event);
                    }
                  },
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
        });
  }
}
