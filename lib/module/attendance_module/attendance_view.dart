import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'attendance_repository.dart';
import 'bloc/attendance_bloc.dart';
import 'model/attendance_model.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Attendance",
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: RepositoryProvider(
        create: (context) => AttendanceRepository(),
        child: BlocProvider(
          create: (context) =>
              AttendanceBloc(context.read())..add(GetAttendanceEvent()),
          child: BlocConsumer<AttendanceBloc, AttendanceState>(
            listenWhen: (previous, current) => current is AttendanceShowSnack,
            listener: (context, state) {
              if (state is AttendanceShowSnack) {
                context.showSnackBarMessage(state.message);
              }
            },
            buildWhen: (previous, current) => current is! AttendanceShowSnack,
            builder: (context, state) {
              if (state is AttendanceLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }
              final bloc = context.read<AttendanceBloc>();
              return Column(
                children: [
                  Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 1.0, // soften the shadow
                            spreadRadius: 1.0, //extend the shadow
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context
                                .read<AttendanceBloc>()
                                .selected
                                .toStringFormat("MMMM yyyy"),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.amber,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                final now = DateTime.now();
                                final date = await showMonthPicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: DateTime(now.year),
                                  lastDate: DateTime(now.year + 1),
                                );

                                if (date != null && context.mounted) {
                                  context
                                      .read<AttendanceBloc>()
                                      .add(MyActivityChangeMonth(date));
                                }
                              },
                              icon: const Icon(
                                Icons.calendar_month,
                                color: ColorConstants.amber,
                              )),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const RowCellAttendance(
                            text: 'Date',
                            isBold: true,
                            textColor: ColorConstants.amber),
                        RowCellAttendance(
                          isBold: true,
                          textColor: Theme.of(context).primaryColor,
                          text: "Start\nDuty",
                        ),
                        const RowCellAttendance(
                          isBold: true,
                          textColor: Colors.red,
                          text: "End\nDuty",
                        ),
                        const RowCellAttendance(
                            isBold: true,
                            textColor: ColorConstants.amber,
                            text: "In"),
                        const RowCellAttendance(
                          isBold: true,
                          textColor: Colors.red,
                          text: "0ut",
                        ),
                        const RowCellAttendance(
                            isBold: true,
                            textColor: Colors.green,
                            text: "Span(Hrs)"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(color: Colors.grey.shade300, height: 1),
                  bloc.attandenceData.isEmpty
                      ? Center(
                          child: TextButton(
                            child: const Text("Retry"),
                            onPressed: () => bloc.add(GetAttendanceEvent()),
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                              itemCount: bloc.attandenceData.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              separatorBuilder: (context, index) => Container(
                                  color: Colors.grey[300]!, height: 1),
                              itemBuilder: (context, index) =>
                                  AttendanceItemView(
                                      index, bloc.attandenceData[index])),
                        )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class AttendanceItemView extends StatelessWidget {
  final int index;
  final AttendanceData attandenceData;

  const AttendanceItemView(this.index, this.attandenceData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          RowCellAttendance(text: attandenceData.date.toStringFormat("dd MMM")),
          RowCellAttendance(text: attandenceData.startDutyTime ?? '-'),
          RowCellAttendance(text: attandenceData.endDutyTime ?? '-'),
          RowCellAttendance(text: attandenceData.firstMarkInTime ?? '-'),
          RowCellAttendance(text: attandenceData.lastMarkOutTime ?? '-'),
          RowCellAttendance(text: attandenceData.timeSpan ?? '-'),
        ],
      ),
    );
  }
}

class RowCellAttendance extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool isBold;
  const RowCellAttendance(
      {super.key,
      required this.text,
      this.textColor = Colors.black,
      this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          fontSize: isBold ? 12.sp : 10.sp,
          color: textColor,
        ),
      ),
    ));
  }
}
