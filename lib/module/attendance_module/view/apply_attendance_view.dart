import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/attendance_module/bloc/attendance_bloc.dart';
import 'package:i_densfa/module/ui/button_views.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/module/ui/speech_input_widgets.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

class ApplyAttendanceView extends StatefulWidget {
  const ApplyAttendanceView({super.key});

  @override
  State<ApplyAttendanceView> createState() => _ApplyAttendanceFormViewState();
}

class _ApplyAttendanceFormViewState extends State<ApplyAttendanceView> {
  late AttendanceBloc bloc;
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();

  final fromTimeController = TextEditingController();
  final toTimeController = TextEditingController();
  final reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final initial = context.read<AttendanceBloc>().reason;
      if (initial.isNotEmpty) {
        reasonController.text = initial;
      }
    });
  }

  @override
  void dispose() {
    bloc.fromDate = null;
    bloc.toDate = null;
    bloc.selectedStartTime = const TimeOfDay(hour: 8, minute: 00);
    bloc.selectedEndTime = const TimeOfDay(hour: 17, minute: 30);
    bloc.reason = "";
    bloc.selectedAttendanceType = null;
    reasonController.dispose();

    super.dispose();
  }

  void _selectFromDate(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
        context: context,
        selectableDayPredicate: (day) {
                                                return 
                                                        !bloc.leavesDate
                                                            .any((element) =>
                                                                element
                                                                    .isSameDate(
                                                                        day) ==
                                                                true) &&
                                                        (day.weekday == DateTime.sunday ? false : true);
                                              },
       
        firstDate: DateTime(now.year, now.month - 1, now.day),
        lastDate: AppStorage().userDetail?.companyName.toLowerCase() == "BrotherInternational".toLowerCase()?  DateTime(now.year, now.month, now.day): DateTime(now.year, now.month, now.day - 1));
    if (date != null && context.mounted) {
      bloc.add(FromDateAttendanceEvent(date));
    }
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
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: BlocConsumer<AttendanceBloc, AttendanceState>(
              listener: (context, state) {
                if (state is AttendanceAppliedSuccess) {
                  Future.delayed(
                      const Duration(seconds: 1),
                      () => {
                            if (context.mounted) {Navigator.pop(context)}
                          });
                }
              },
              builder: (context, state) {
                final textTheme = Theme.of(context).textTheme;
                final theme = Theme.of(context);
                bloc = context.read<AttendanceBloc>();
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
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Text(
                            AppStorage()
                                        .userDetail
                                        ?.companyName
                                        .toLowerCase() ==
                                    "contractor"
                                ? 'Log activity'
                                : 'Apply attendance',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Submit times for approval by your manager.',
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 20.h),
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
                                    Text('From',
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        )),
                                    SizedBox(height: 6.h),
                                    BlocListener<AttendanceBloc,
                                        AttendanceState>(
                                      listener: (context, state) {
                                        final fromDate = bloc.fromDate;
                                        if (fromDate != null) {
                                          fromDateController.text = fromDate
                                              .toStringFormat("dd/MM/yyyy");
                                        }
                                      },
                                      child: TextFormField(
                                        controller: fromDateController,
                                        decoration: _fieldDecoration(
                                          context,
                                          'DD/MM/YYYY',
                                          suffix: Icon(
                                            Icons.calendar_month_rounded,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () =>
                                            _selectFromDate(context),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('To',
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        )),
                                    SizedBox(height: 6.h),
                                    BlocListener<AttendanceBloc,
                                        AttendanceState>(
                                      listener: (context, state) {
                                        final fromDate = bloc.toDate;
                                        if (fromDate != null) {
                                          toDateController.text = fromDate
                                              .toStringFormat("dd/MM/yyyy");
                                        }
                                      },
                                      child: TextFormField(
                                        controller: toDateController,
                                        decoration: _fieldDecoration(
                                          context,
                                          'DD/MM/YYYY',
                                          suffix: Icon(
                                            Icons.calendar_month_rounded,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () async {
                                          final now = DateTime.now();
                                          final date = await showDatePicker(
                                            context: context,
                                            selectableDayPredicate: (day) {
                                              return !bloc.leavesDate.any(
                                                      (element) =>
                                                          element.isSameDate(
                                                              day) ==
                                                          true) &&
                                                  (day.weekday ==
                                                          DateTime.sunday
                                                      ? false
                                                      : true);
                                            },
                                            firstDate: DateTime(now.year,
                                                now.month - 1, now.day),
                                            lastDate:AppStorage().userDetail?.companyName.toLowerCase() == "BrotherInternational".toLowerCase()?  DateTime(now.year, now.month, now.day): DateTime(now.year, now.month, now.day - 1),
                                          );
                                          if (date != null &&
                                              context.mounted) {
                                            bloc.add(
                                                ToDateAttendanceEvent(date));
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            'Time',
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
                                    Text('From time',
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        )),
                                    SizedBox(height: 6.h),
                                    BlocListener<AttendanceBloc,
                                        AttendanceState>(
                                      listener: (context, state) {
                                        fromTimeController.text = bloc
                                            .selectedStartTime
                                            .toStringFormat("HH:mm");
                                      },
                                      child: TextFormField(
                                        controller: fromTimeController
                                          ..text = bloc.selectedStartTime
                                              .toStringFormat("HH:mm"),
                                        decoration: _fieldDecoration(
                                          context,
                                          'HH:mm',
                                          suffix: Icon(
                                            Icons.schedule_rounded,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () async => {
                                          await bloc
                                              .selectTime(context,
                                                  bloc.selectedStartTime)
                                              .then((picked) {
                                            if (picked != null &&
                                                picked !=
                                                    bloc.selectedStartTime) {
                                              bloc.selectedStartTime = picked;
                                              bloc.add(DateChangedEvent());
                                            }
                                          })
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('To time',
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        )),
                                    SizedBox(height: 6.h),
                                    BlocListener<AttendanceBloc,
                                        AttendanceState>(
                                      listener: (context, state) {
                                        toTimeController.text = bloc
                                            .selectedEndTime
                                            .toStringFormat("HH:mm");
                                      },
                                      child: TextFormField(
                                        controller: toTimeController
                                          ..text = bloc.selectedEndTime
                                              .toStringFormat("HH:mm"),
                                        decoration: _fieldDecoration(
                                          context,
                                          'HH:mm',
                                          suffix: Icon(
                                            Icons.schedule_rounded,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () async {
                                          await bloc
                                              .selectTime(context,
                                                  bloc.selectedEndTime)
                                              .then((picked) {
                                            if (picked != null &&
                                                picked !=
                                                    bloc.selectedEndTime) {
                                              bloc.selectedEndTime = picked;
                                              bloc.add(DateChangedEvent());
                                            }
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          // if ((AppStorage().userDetail?.companyName ?? '').toLowerCase().trim() == 'brotherinternational') ...[
                          //   SizedBox(height: 18.h),
                          //   Text(
                          //     'Attendance type',
                          //     style: textTheme.titleSmall?.copyWith(
                          //       fontWeight: FontWeight.w700,
                          //     ),
                          //   ),
                          //   SizedBox(height: 8.h),
                          //   DropDownSearchWidget<String>(
                          //     filterFn: (items, value) =>
                          //         items
                          //             ?.trim()
                          //             .toLowerCase()
                          //             .contains(value.trim().toLowerCase()) ??
                          //         false,
                          //     listItemWidget: (item) => Text(
                          //       item ?? "NA",
                          //       style: Theme.of(context).textTheme.titleSmall,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //     selectedWidget: Text(
                          //       context.select((AttendanceBloc value) =>
                          //               value.selectedAttendanceType) ??
                          //           "Please select attendance type",
                          //       style: Theme.of(context).textTheme.titleSmall,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //     enabled: true,
                          //     options: AttendanceBloc.attendanceTypeOptions,
                          //     hint: "Please select attendance type",
                          //     selectedVal: context.select(
                          //         (AttendanceBloc value) =>
                          //             value.selectedAttendanceType),
                          //     valChanged: (value) {
                          //       if (value != null) {
                          //         bloc.selectedAttendanceType = value;
                          //         bloc.add(DateChangedEvent());
                          //       }
                          //     },
                          //   ),
                          // ],
                          SizedBox(height: 18.h),
                          Text(
                            'Reason',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TapRegion(
                            onTapOutside: (_) => context.hideKeyboard(),
                            child: SpeechEnabledTextFormField(
                              controller: reasonController,
                              decoration: _fieldDecoration(
                                context,
                                'Explain why you need this adjustment (type or speak)…',
                              ).copyWith(
                                alignLabelWithHint: true,
                              ),
                              minLines: 3,
                              maxLines: 5,
                              textInputAction: TextInputAction.done,
                              onChanged: (value) => bloc.reason = value,
                            ),
                          ),
                          SizedBox(height: 22.h),
                          CustomButton(
                            buttonText: "Submit for approval",
                            onPressed: () {
                              context.hideKeyboard();
                              if (state is! LoadingState) {
                                bloc.add(ApplyNewAttendance());
                              }
                            },
                            isLoading: state is LoadingState,
                            isSuccess: state is AttendanceAppliedSuccess,
                          ),
                          SizedBox(height: 8.h),
                        ]));
              },
            )));
  }
}
