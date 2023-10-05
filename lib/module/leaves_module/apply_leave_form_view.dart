import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../ui/button_views.dart';
import '../ui/custom_material_button.dart';
import 'leave/leave_bloc.dart';
import 'model/leave_enums.dart';

class ApplyLeaveFormView extends StatefulWidget {
  const ApplyLeaveFormView({super.key});

  @override
  State<ApplyLeaveFormView> createState() => _ApplyLeaveFormViewState();
}

class _ApplyLeaveFormViewState extends State<ApplyLeaveFormView> {
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  late LeaveBloc bloc;

  @override
  void dispose() {
    bloc.fromDate = null;
    bloc.toDate = null;
    bloc.selectLeaveType = null;
    bloc.selectedLeaveDayPart = LeaveDayPart.full;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: BlocConsumer<LeaveBloc, LeaveState>(
          listenWhen: (previous, current) => current is LeaveAppliedSuccess,
          listener: (context, state) => Navigator.pop(context),
          builder: (context, state) {
            final textTheme = Theme.of(context).textTheme;
            bloc = context.read<LeaveBloc>();
            if (state is LeaveApplyLoadingState) {
              return SizedBox(
                  height: 1.sh - 100,
                  child: const Center(child: CircularProgressIndicator()));
            }
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "Apply for leave",
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Leave Type", style: textTheme.labelLarge),
                  const SizedBox(height: 5),
                  DropDownWithOptions(
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
                            Text(
                                (bloc.selectedLeaveDayPart == LeaveDayPart.full)
                                    ? "From"
                                    : "On",
                                style: textTheme.labelLarge),
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
                                    fromDateController.text =
                                        fromDate.toStringFormat("dd/MM/yyyy");
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
                                  onTap: () => _selectFromDate(context),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      if (bloc.selectedLeaveDayPart == LeaveDayPart.full)
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
                                      toDateController.text =
                                          fromDate.toStringFormat("dd/MM/yyyy");
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
                                        initialDate: bloc.fromDate ?? now,
                                        firstDate: bloc.fromDate ?? now,
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
                      onTapOutside: (event) {
                        context.hideKeyboard();
                      },
                      textInputAction: TextInputAction.done,
                      onChanged: (value) => bloc.reason = value,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomMaterialButton(
                      buttonText: state is LoadingState
                          ? "Loading.."
                          : "Submit for Approval",
                      onPressed: () {
                        context.hideKeyboard();
                        if (state is! LoadingState) {
                          bloc.add(ApplyNewLeave());
                        }
                      }),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }),
    ));
  }

  void _selectFromDate(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year, 12, 31));
    if (date != null && context.mounted) {
      bloc.add(FromDateLeaveTypeEvent(date));
    }
  }
}
