import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/assessment_module/bloc/assessment_bloc.dart';
import 'package:i_densfa/utility/extensions.dart';

import '../../dynamic_questions_module/views/dynamic_questions_view.dart';

class AssessmentQuestionsView extends StatelessWidget {
  const AssessmentQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final AssessmentBloc bloc = context.read();

    return WillPopScope(
      onWillPop: () async {
        final response = await _showQuitWarning(context, bloc);
        if (response == "Yes") {
          bloc.add(SaveAssessmentAnswersEvent(false));
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Assessment"),
          actions: [
            BlocBuilder<AssessmentBloc, AssessmentState>(
              buildWhen: (previous, current) =>
                  current is TimerUpdateAssessmentState,
              builder: (context, state) {
                if (state is TimerUpdateAssessmentState) {
                  return Text(
                    state.leftTime,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  );
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocConsumer<AssessmentBloc, AssessmentState>(
                listenWhen: (previous, current) =>
                    current is SnackbarMessageAssessmentState ||
                    current is ScoreCalculatedAssessmentState,
                listener: (context, state) {
                  if (state is SnackbarMessageAssessmentState) {
                    context.showSnackBarMessage(state.message);
                  } else if (state is ScoreCalculatedAssessmentState) {
                    Navigator.pop(context);
                  }
                },
                buildWhen: (previous, current) =>
                    current is AssessmentQuestionsLoadedState,
                builder: (context, state) =>
                    DynamicQuestionsView(questions: bloc.questionAnswers),
              ),
              Align(
                  child: FilledButton(
                      style: TextButton.styleFrom(
                        elevation: 2,
                        alignment: Alignment.center,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: bloc.state is SavingAnswersLoadingState
                          ? null
                          : () => bloc.add(SaveAssessmentAnswersEvent(true)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "SUBMIT",
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      )))
            ],
          ),
        ),
      ),
    );
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
}
