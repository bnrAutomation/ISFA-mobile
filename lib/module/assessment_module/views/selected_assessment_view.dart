import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:i_densfa/module/assessment_module/bloc/assessment_bloc.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_storage.dart';

class SelectedAssessmentView extends StatelessWidget {
  const SelectedAssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final AssessmentBloc bloc = context.read();
    return Scaffold(
      backgroundColor: const Color(0xffBFD1DF),
      appBar: AppBar(
          backgroundColor: theme.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Assessment",
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(radius: 25.w),
                title: Text(AppStorage().userDetail!.username),
                subtitle: Text(AppStorage().userDetail!.supervisor),
              ),
            ),
            Card(
              child: ListTile(
                textColor: theme.primaryColor,
                horizontalTitleGap: 0,
                leading: Icon(
                  Icons.calendar_month_outlined,
                  color: theme.primaryColor,
                ),
                title: const Text("Change Date"),
                subtitle: Text(
                    "From: ${bloc.selectedAssessment!.startDate} To: ${bloc.selectedAssessment!.endDate}"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FilledButton(
                  onPressed: () => context
                      .pushNamed(AppPaths.assessmentQuestion, extra: bloc),
                  style: TextButton.styleFrom(
                    elevation: 2,
                    alignment: Alignment.center,
                    backgroundColor: theme.primaryColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text('Enter Questionnaire',
                        style: GoogleFonts.inter(
                            fontSize: 14.sp, color: Colors.white)),
                  )),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  children: [
                    Text(
                      "Your Score",
                      style: textTheme.titleLarge,
                    ),
                    yourScoreChart(context),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        ChartIndicator(
                          color: theme.primaryColor,
                          text: 'Targets Completed',
                        ),
                        const SizedBox(height: 4),
                        const ChartIndicator(
                          color: Color(0xffEABB55),
                          text: 'Targets Missed',
                        ),
                        const SizedBox(height: 4),
                        const ChartIndicator(
                          color: Color(0xffDB4C5B),
                          text: 'Targets Failed',
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "13542",
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp),
                    ),
                    const Text("Sub Dealer Targeted"),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.w),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey.shade400,
                        color: Theme.of(context).primaryColor,
                        minHeight: 40,
                        value: 0.88,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      "63",
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp),
                    ),
                    const Text("Sub Dealer Included in Responses"),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.w),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey.shade400,
                        color: const Color(0xffDB4C5B),
                        minHeight: 40,
                        value: 0.4,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      "568",
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp),
                    ),
                    const Text("Total Responses"),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.w),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey.shade400,
                        color: const Color(0xffFFBF00),
                        minHeight: 40,
                        value: 0.7,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget yourScoreChart(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 2.2,
      child: BlocBuilder<AssessmentBloc, AssessmentState>(
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(25.w),
                child: Center(
                  child: Text(
                    "85/100",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      var index = -1;
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        return;
                      }
                      index =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                      context
                          .read<AssessmentBloc>()
                          .add(AssessmentTouchChanged(index));
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0.5,
                  centerSpaceRadius: 50,
                  startDegreeOffset: 270,
                  sections: showingSections(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> showingSections(BuildContext context) {
    final bloc = context.read<AssessmentBloc>();
    final theme = Theme.of(context);
    return List.generate(bloc.pieChartReportData.length, (i) {
      final isTouched = i == bloc.selectedPieChartPortionId;
      final fontSize = isTouched ? 13.sp : 10.sp;
      final radius = isTouched ? 25.0 : 20.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      final val = bloc.pieChartReportData[i];
      final color = i == 0
          ? theme.primaryColor
          : i == 1
              ? const Color(0xffEABB55)
              : const Color(0xffDB4C5B);
      return PieChartSectionData(
        color: color,
        value: val.toDouble(),
        title: val.toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}

class ChartIndicator extends StatelessWidget {
  const ChartIndicator({
    super.key,
    required this.color,
    required this.text,
    this.isSquare = true,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
