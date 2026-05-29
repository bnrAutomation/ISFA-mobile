import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/assessment_module/assessment/assessment_bloc.dart';
import 'package:i_densfa/routes.dart';

class LevelView extends StatelessWidget {
  const LevelView({super.key});
  @override
  Widget build(BuildContext context) {
    final AssessmentBloc bloc = context.read();
    return Scaffold(
      appBar: AppBar(title: Text(bloc.selectedAssessment?.name ?? "Level")),
      body: BlocConsumer<AssessmentBloc, AssessmentState>(
        builder: (context, state) {
          final list = bloc.assessmentLevel;
          if (state is AssessmentListLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (list.isEmpty) {
            return const Center(child: Text("Level not found"));
          }
          return ListView.separated(
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
                  title: Text(item.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white)),
                  subtitle: Text(
                    "Require to Achieve Score : ${item.score}",
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  trailing: item.status
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              Text(
                                "Pass",
                                style: TextStyle(fontSize: 10.sp),
                              )
                            ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.isUnlocked
                                  ? Icons.lock_open
                                  : Icons.lock_outlined,
                              color:
                                  item.isUnlocked ? Colors.green : Colors.white,
                            ),
                            Text(
                              item.isUnlocked ? "Un-Lock" : "Lock",
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          ],
                        ),
                  onTap: () {
                    if (item.status) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Level has already completed")));
                    } else if (item.givenAttempts >= item.totalAttempts) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("You exceed maximum attempted limit.")));
                    } else if (!item.isUnlocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item.name} is Locked.")));
                    } else {
                      bloc.add(GetSectionEvent(item));
                      context
                          .pushNamed(AppPaths.assessmentQuestion,
                              extra: bloc
                                ..add(
                                    StartQuestionCountDownTimerAssessmentEvent()))
                          .then((value) => {
                                bloc.add(GetAssessmentLevel(
                                    bloc.selectedAssessment!))
                              });
                    }
                  },
                ),
              );
            },
          );
        },
        listener: (BuildContext context, AssessmentState state) {
          if (state is SnackbarMessageState) {
            //context.showSnackBarMessage(state.message);
          }
        },
      ),
    );
  }
}
