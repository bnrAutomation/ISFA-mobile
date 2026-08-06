import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/module/ui/speech_input_widgets.dart';
import 'package:i_densfa/module/ui/dialog_helper.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../ui/button_views.dart';
import 'leave/leave_bloc.dart';
import 'model/leave_enums.dart';

class ApplyLeaveFormView extends StatefulWidget {
  const ApplyLeaveFormView({super.key});

  @override
  State<ApplyLeaveFormView> createState() => _ApplyLeaveFormViewState();
}

class _ApplyLeaveFormViewState extends State<ApplyLeaveFormView> {
  late LeaveBloc bloc;
  final maternatyDateController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  @override
  void dispose() {
    bloc.fromDate = null;
    bloc.toDate = null;
    bloc.maternityDate = null;
    bloc.selectLeaveType = null;
    bloc.selectedLeaveDayPart = LeaveDayPart.full;
    bloc.leaveDescreption = "";
    super.dispose();
  }

  void _selectMaternatyDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime initial = getValidInitialDate();
    final date = await showDatePicker(
        context: context,
        selectableDayPredicate: (day) {
          return bloc.selectLeaveType?.trim().toLowerCase() ==
                  "maternity leave".trim()
              ? true
              : !bloc.optionalLeave.any((element) =>
                      element.canChange == false &&
                      element.date?.isSameDate(day) == true) &&
                  !bloc.upcommingLeave.any(
                      (element) => element.date?.isSameDate(day) == true) &&
                  !bloc.leavesDate
                      .any((element) => element.isSameDate(day) == true);
          //                                               &&
          // !bloc.weekoff
          //     .any((element) => element.isSameDate(day) == true);
        },
        initialDate: initial,
        firstDate: DateTime(now.year, now.month - 1, now.day),
        lastDate: DateTime(now.year + 1, 12, 31));
    if (date != null && context.mounted) {
      bloc.add(MeternatiyLeaveTypeEvent(date));
    }
  }

  DateTime getValidInitialDate() {
    DateTime date = DateTime.now();

    // Special case: maternity leave allows all days
    if (bloc.selectLeaveType?.trim().toLowerCase() == "maternity leave") {
      return date;
    }

    // Find next valid date based on your predicate
    while (!isValidDay(date)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  bool isValidDay(DateTime day) {
    return !bloc.optionalLeave.any((element) =>
            element.canChange == false &&
            element.date?.isSameDate(day) == true) &&
        !bloc.upcommingLeave
            .any((element) => element.date?.isSameDate(day) == true) &&
        !bloc.leavesDate.any((element) => element.isSameDate(day) == true);
    //                                                         &&
    //  !bloc.weekoff.any((element) => element.isSameDate(day) == true);
  }

  InputDecoration _fieldDecoration(BuildContext context, String hint,
      {Widget? suffix}) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.dividerColor.withValues(alpha: 0.65),
      ),
    );
    return InputDecoration(
      suffixIcon: suffix,
      hintText: hint,
      filled: true,
      fillColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
    );
  }

  void _selectFromDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime initial = getValidInitialDate();
    final date = await showDatePicker(
        context: context,
        selectableDayPredicate: (day) {
          return bloc.selectLeaveType?.trim().toLowerCase() ==
                  "maternity leave".trim()
              ? true
              : !bloc.optionalLeave.any((element) =>
                      element.canChange == false &&
                      element.date?.isSameDate(day) == true) &&
                  !bloc.upcommingLeave.any(
                      (element) => element.date?.isSameDate(day) == true) &&
                  !bloc.leavesDate
                      .any((element) => element.isSameDate(day) == true);

          //                                               &&
          // !bloc.weekoff
          //     .any((element) => element.isSameDate(day) == true);
        },
        initialDate: initial,
        firstDate: DateTime(now.year, now.month - 1, now.day),
        lastDate: DateTime(now.year + 1, 12, 31));
    if (date != null && context.mounted) {
      bloc.add(FromDateLeaveTypeEvent(date));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: BlocConsumer<LeaveBloc, LeaveState>(
          listenWhen: (previous, current) =>
              current is LeaveAppliedSuccess || current is LeaveViewShowSnack,
          listener: (context, state) => {
                if (state is LeaveAppliedSuccess)
                  {
                    DialogHelper.showErrorMessage(
                        context, "Message", state.message,
                        onOkayClick: () => {
                              Navigator.pop(context),
                              Navigator.pop(context),
                            })

                    // Future.delayed(const Duration(seconds: 1), () {
                    //   if (context.mounted) {
                    //     Navigator.pop(context);
                    //      DialogHelper.showErrorMessage(
                    //   context, "Message", state.message);
                    //   }
                    // })
                  },
              },
          builder: (context, state) {
            final textTheme = Theme.of(context).textTheme;
            bloc = context.read<LeaveBloc>();
            if (state is LeaveApplyLoadingState) {
              return SizedBox(
                  height: 1.sh - 100,
                  child: const Center(child: CircularProgressIndicator()));
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    'Apply for leave',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Choose type, dates, and submit for approval.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Leave type',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                   DropDownSearchWidget<String>(
                     filterFn: (items, value) => items?.trim().toLowerCase().contains(value.trim().toLowerCase()) ?? false,
                  listItemWidget: (userItems) => Text(
                    userItems ?? "NA",
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selectedWidget: Text(
                   
                         context
                        .select((LeaveBloc value) => value.selectLeaveType)??
                           "Please select leave type",
                       
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                    enabled: true,
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
                  bloc.selectLeaveType?.trim().toLowerCase() ==
                          "maternity leave".trim()
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.h),
                            Text(
                              'Expected delivery date',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            BlocListener<LeaveBloc, LeaveState>(
                              listener: (context, state) {
                                final maternityDate = bloc.maternityDate;
                                if (maternityDate != null) {
                                  maternatyDateController.text = maternityDate
                                      .toStringFormat('dd/MM/yyyy');
                                }
                              },
                              child: TextFormField(
                                controller: maternatyDateController,
                                decoration: _fieldDecoration(
                                  context,
                                  'DD/MM/YYYY',
                                  suffix: Icon(
                                    Icons.calendar_month_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                readOnly: true,
                                onTap: () => _selectMaternatyDate(context),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  SizedBox(height: 18.h),
                  Text(
                    'Day part',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // AppStorage().userDetail?.companyName.toLowerCase().trim()=="brotherinternational"?
                  //  SizedBox(
                  //   width: 1.sw,
                  //   child: CupertinoSlidingSegmentedControl<LeaveDayPartBI>(
                  //       padding: const EdgeInsets.all(0),
                  //       // thumbColor: Theme.of(context).colorScheme.onSurface,
                  //       groupValue: context.select((LeaveBloc value) => value.selectedLeaveDayPart),
                  //       children: {
                  //         for (var partName in LeaveDayPartBI.values)
                  //           partName: Center(child: Text(partName.name))
                  //       },
                  //       onValueChanged: (val) {
                  //         if (val != null) {
                  //           bloc.add(ChangeLeaveDayPartEvent(val));
                  //         }
                  //       }),
                  // ):
                  Material(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: SizedBox(
                        width: 1.sw,
                        child: CupertinoSlidingSegmentedControl<LeaveDayPart>(
                            padding: const EdgeInsets.all(0),
                            groupValue: context.select(
                                (LeaveBloc value) => value.selectedLeaveDayPart),
                            children: getChild(),
                            onValueChanged: (val) {
                              if (val != null) {
                                bloc.add(ChangeLeaveDayPartEvent(val));
                              }
                            }),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Dates',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                (bloc.selectedLeaveDayPart ==
                                            LeaveDayPart.full) ||
                                        bloc.selectLeaveType
                                                ?.trim()
                                                .toLowerCase() !=
                                            "weekly off".trim()
                                    ? 'From'
                                    : 'On',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                )),
                            SizedBox(height: 6.h),
                            BlocListener<LeaveBloc, LeaveState>(
                              listener: (context, state) {
                                final fromDate = bloc.fromDate;
                                if (fromDate != null) {
                                  fromDateController.text =
                                      fromDate.toStringFormat('dd/MM/yyyy');
                                }
                              },
                              child: TextFormField(
                                controller: fromDateController,
                                decoration: _fieldDecoration(
                                  context,
                                  'DD/MM/YYYY',
                                  suffix: Icon(
                                    Icons.calendar_month_rounded,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                readOnly: true,
                                onTap: () => _selectFromDate(context),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      if (bloc.selectedLeaveDayPart == LeaveDayPart.full)
                        bloc.selectLeaveType?.trim().toLowerCase() !=
                                "weekly off".trim()
                            ? Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('To',
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        )),
                                    SizedBox(height: 6.h),
                                    BlocListener<LeaveBloc, LeaveState>(
                                      listener: (context, state) {
                                        final fromDate = bloc.toDate;
                                        if (fromDate != null) {
                                          toDateController.text = fromDate
                                              .toStringFormat('dd/MM/yyyy');
                                        }
                                      },
                                      child: TextFormField(
                                        controller: toDateController,
                                        decoration: _fieldDecoration(
                                          context,
                                          'DD/MM/YYYY',
                                          suffix: Icon(
                                            Icons.calendar_month_rounded,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () async {
                                          final now = DateTime.now();
                                          DateTime initial =
                                              getValidInitialDate();
                                          final date = await showDatePicker(
                                            context: context,
                                            selectableDayPredicate: (day) {
                                              return bloc.selectLeaveType
                                                          ?.trim()
                                                          .toLowerCase() ==
                                                      "maternity leave".trim()
                                                  ? true
                                                  : !bloc.optionalLeave.any(
                                                          (element) =>
                                                              element.canChange ==
                                                                  false &&
                                                              element.date?.isSameDate(day) ==
                                                                  true) &&
                                                      !bloc.upcommingLeave
                                                          .any((element) =>
                                                              element.date
                                                                  ?.isSameDate(
                                                                      day) ==
                                                              true) &&
                                                      !bloc.leavesDate
                                                          .any((element) => element.isSameDate(day) == true);
                                              //         &&
                                              // !bloc.weekoff
                                              //     .any((element) => element.isSameDate(day) == true);
                                            },
                                            initialDate:
                                                bloc.fromDate ?? initial,
                                            firstDate: DateTime(now.year,
                                                now.month - 1, now.day),
                                            lastDate: DateTime(
                                                now.year + 1, 12, 31),
                                          );
                                          if (date != null &&
                                              context.mounted) {
                                            bloc.add(
                                                ToDateLeaveTypeEvent(date));
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : const SizedBox()
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Reason',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SpeechEnabledTextFormField(
                    decoration: _fieldDecoration(
                      context,
                      'Explain why you need this leave…',
                    ),
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) => bloc.reason = value,
                  ),
                  SizedBox(height: 18.h),
                  CustomButton(
                    buttonText: 'Submit for approval',
                    onPressed: () {
                      context.hideKeyboard();
                      if (state is! LoadingState) {
                        bloc.add(ApplyNewLeave());
                      }
                    },
                    isLoading: state is LoadingState,
                    isSuccess: state is LeaveAppliedSuccess,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bloc.leaveDescreption,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.red),
                  )
                ],
              ),
            );
          }),
    ));
  }

  getChild() {
    final filteredList = LeaveDayPart.values.toList();
        // (AppStorage().userDetail?.companyName.toLowerCase().trim() ==
        //         "brotherinternational")
        //     ? LeaveDayPart.values
        //         .where((e) =>
        //             e != LeaveDayPart.firstHalf && e != LeaveDayPart.secondHalf)
        //         .toList()
        //     : LeaveDayPart.values.where((e) => e != LeaveDayPart.half).toList();
    return {
      for (var partName in filteredList)
        partName: Center(child: Text(partName.name))
    };
  }
}
