import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/assessment_module/bloc/assessment_bloc.dart';

import '../../dynamic_questions_module/model.dart';
import '../../dynamic_questions_module/views/dynamic_questions_view.dart';

class AssessmentQuestionsView extends StatelessWidget {
  const AssessmentQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final AssessmentBloc bloc = context.read();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Assessment",
            style: textTheme.titleMedium?.copyWith(color: Colors.white),
          )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DynamicQuestionsView(
                questions: bloc.selectedAssessQuestions.map((e) {
              return QuestionModel(
                  isRequired: true,
                  options: e.options,
                  question: e.questionText,
                  questionType: e.questionType,
                  placholder: e.questionText);
            }).toList()),
            Align(
                child: FilledButton(
                    style: TextButton.styleFrom(
                      elevation: 2,
                      alignment: Alignment.center,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    )))
          ],
        ),
      ),
    );
  }
}
