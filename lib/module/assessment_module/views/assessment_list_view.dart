import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/assessment_module/assessment_repository.dart';
import 'package:i_densfa/module/assessment_module/bloc/assessment_bloc.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/extensions.dart';

class AssessmentListView extends StatelessWidget {
  const AssessmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assessment")),
      body: BlocProvider(
        lazy: false,
        create: (context) => AssessmentBloc(AssessmentRepository())
          ..add(GetUserAssessmentsEvent()),
        child: BlocBuilder<AssessmentBloc, AssessmentState>(
          builder: (context, state) {
            final bloc = context.read<AssessmentBloc>();
            final list = bloc.userAssessments;
            if (state is AssessmentListLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (list.isEmpty) {
              return const Center(child: Text("No assessment assigned"));
            }
            return AnimationLimiter(
              child: ListView.separated(
                padding: EdgeInsets.all(10.w),
                itemCount: list.length,
                separatorBuilder: (context, index) => SizedBox(height: 4.h),
                itemBuilder: (context, index) {
                  final item = list[index];
                  final colors = [
                    const Color(0XFF003D5B),
                    const Color(0xffDB4C5B),
                    ColorConstants.amber,
                    const Color(0xff464646),
                  ];
                  final colr = index < colors.length
                      ? colors[index]
                      : colors[index % colors.length];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Card(
                          color: colr,
                          child: ListTile(
                            textColor: Colors.white,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(item.name)),
                                //if (DateTime.now().isAfter(DateTime.parse(item.endDate)))
                                if (item.isNagative())
                                  const Text(
                                    "Ended",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                if (item.userScored != null)
                                  const Text(
                                    "Filled",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                              ],
                            ),
                            subtitle: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "${item.startDate.toStringFormat("dd-MM-yyyy")} - ${item.endDate.toStringFormat("dd-MM-yyyy")}",
                                style: TextStyle(fontSize: 10.sp),
                              ),
                            ),
                            onTap: () {
                              bloc.add(
                                  GetQuestionsForAssessment(item.assessmentId));
                              context.pushNamed(AppPaths.assessment,
                                  extra: bloc);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
