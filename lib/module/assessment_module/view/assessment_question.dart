import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/assessment_module/assessment/assessment_bloc.dart';
import 'package:i_densfa/module/dynamic_questions_module/views/dynamic_questions_view.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/custom_tab_view.dart';
import 'package:i_densfa/utility/extensions.dart';

class AssessmentQuestionsView extends StatelessWidget {
  const AssessmentQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AssessmentBloc bloc = context.read();
    bool isDialogShowing = false;
    return PopScope(
      onPopInvokedWithResult: (value, result) async {
        if (isDialogShowing) return;
        isDialogShowing = true;
        final response = await _showQuitWarning(context, bloc);
        // ignore: unrelated_type_equality_checks
        if (response == true && context.mounted) {
          Navigator.pop(context);
        }

        //return false;
      },
      child: Scaffold(
        floatingActionButton: Align(
          alignment: const Alignment(1.03, 0.87),
          child: FloatingActionButton(
              tooltip: 'Timer',
              backgroundColor: (bloc.secondsTook ~/ 60) >=
                      (bloc.selectedAssessmentLevel?.timeLimit ?? 1)
                  ? Colors.red
                  : Colors.green,
              child: BlocBuilder<AssessmentBloc, AssessmentState>(
                buildWhen: (previous, current) =>
                    current is TimerUpdateAssessmentState,
                builder: (context, state) {
                  if (state is TimerUpdateAssessmentState) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          Text(
                            state.leftTime,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              onPressed: () {}),
        ),
        appBar: AppBar(
          title: Text(bloc.selectedAssessmentLevel?.name ?? "Assessment Level"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocConsumer<AssessmentBloc, AssessmentState>(
                listener: (context, state) {
                  if (state is SnackbarMessageState) {
                    context.showSnackBarMessage(state.message);
                  }
                  if (state is ScoreCalculatedAssessmentState) {
                    bloc.questionAnswers.clear();

                    context.replaceNamed(AppPaths.assessmentResult,
                        extra: bloc);
                  }
                },
                buildWhen: (previous, current) =>
                    current is AssessmentQuestionsLoadedState ||
                    current is SavingAnswersLoadingState ||
                    current is OptionChangeState,
                builder: (context, state) => CustomTabView(
                  itemCount: bloc.selectedAssessmentFormSections.length,
                  onPositionChange: (value) => bloc.add(GetQuestionsForSection(
                      bloc.selectedAssessmentFormSections[value].uuid)),
                  tabBuilder: (context, index) => DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: Tab(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child:
                          Text(bloc.selectedAssessmentFormSections[index].name),
                    )),
                  ),
                  pageBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: bloc.selectedAssessmentFormSections[index].uuid ==
                            bloc.lastSelectedSectionUuid
                        ? Stack(
                            children: [
                              DynamicQuestionsView(
                                name: 'assessment',
                                questions: bloc.questionAnswers,
                                onImageUpload: (questionUuid, path, isIssue,index) {
                                  bloc.add(UploadImageEvent(
                                      questionUuid, path, isIssue));
                                },
                                onAnswerUpdate:
                                    (String question, String answer, int questionOrder) {
                                  bloc.add(
                                      AnswerUpdatedAssessmentEvent(question));
                                },
                              ),
                              BlocBuilder<AssessmentBloc, AssessmentState>(
                                builder: (context, state) =>
                                    (state is AssessmentListLoadingState)
                                        ? const Positioned.fill(
                                            child: ColoredBox(
                                                color: Colors.white10,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 10),
                                                    Text('Loading...')
                                                  ],
                                                )))
                                        : const SizedBox(),
                              )
                            ],
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
            ),
            Align(
                child: InkWell(
              onTap: bloc.state is SavingAnswersLoadingState
                  ? null
                  : () => bloc.add(SaveAssessmentAnswersEvent(true)),
              child: Container(
                  width: 1.sw,
                  height: 50.h,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xff333333)),
                  child: Text(
                    context.select((AssessmentBloc bloc) =>
                        bloc.state is SavingAnswersLoadingState
                            ? "Loading..."
                            : "SUBMIT"),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  )),
            ))
          ],
        ),
      ),
    );
  }
}

Future<String?> _showQuitWarning(BuildContext context, AssessmentBloc bloc) {
  return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text("Are you sure you want to quit assessment"),
          cancelButton: TextButton(
              onPressed: () => Navigator.pop(context, 'No'),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.red),
              )),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, 'Yes'),
                child: const Text('Yes')),
          ],
        );
      });
}
