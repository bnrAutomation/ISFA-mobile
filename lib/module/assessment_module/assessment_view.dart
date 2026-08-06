import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/assessment_module/assessment/assessment_bloc.dart';
import 'package:i_densfa/module/assessment_module/assessment_repository.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:upgrader/upgrader.dart';

class AssessmentView extends StatelessWidget {
  final String name;
  const AssessmentView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(seconds: 10)),
      shouldPopScope: () => false,
      showIgnore: false,
      showLater: false,
      navigatorKey: router.routerDelegate.navigatorKey,
      child: Scaffold(
        appBar: AppBar(title: Text(name)),
        body: RepositoryProvider(
          create: (context) => AssessmentRepository(),
          child: BlocProvider(
            lazy: false,
            create: (context) =>
                AssessmentBloc(context.read())..add(GetAssessmentEvent()),
            child: BlocBuilder<AssessmentBloc, AssessmentState>(
              builder: (context, state) {
                final bloc = context.read<AssessmentBloc>();
                final list = bloc.assessmentList;
                if (state is AssessmentListLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (list.isEmpty) {
                  return const Center(child: Text("No assessment assigned"));
                }
                return ListView.separated(
                  padding: EdgeInsets.all(10.w),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => SizedBox(height: 4.h),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final colors = [
                      const Color(0XFF003D5B),
                      const Color(0xffDB4C5B),
                      const Color(0xffFFBE00),
                      const Color(0xff464646),
                    ];
                    final color = index < colors.length
                        ? colors[index]
                        : colors[index % colors.length];
                    return Card(
                      color: color,
                      child: ListTile(
                        textColor: Colors.white,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.name),
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
                          bloc.add(GetAssessmentLevel(item));
                          context
                              .pushNamed(AppPaths.assessmentlevel, extra: bloc)
                              .then(
                                  (value) => {bloc.add(GetAssessmentEvent())});
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
