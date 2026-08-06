import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/dynamic_questions_module/views/dynamic_questions_view.dart';
import 'package:i_densfa/module/survey_module/bloc/survey_bloc.dart';
import 'package:i_densfa/utility/custom_tab_view.dart';

class SurveyQuestionsView extends StatelessWidget {
  const SurveyQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SurveyBloc bloc = context.read();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // If already popped, do nothing
        if (didPop) {
          return;
        }
        
        // Show the warning dialog
        final response = await _showQuitWarning(context, bloc);
        
        // If user confirmed, manually pop
        if (response == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(bloc.selectedSurvey?.name ?? "Survey")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocConsumer<SurveyBloc, SurveyState>(
                listener: (context, state) {
                  if (state is ScoreCalculatedSurveyState) {
                    bloc.questionAnswers.clear();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                buildWhen: (previous, current) =>
                    current is SurveyQuestionsLoadedState ||
                    current is SavingAnswersLoadingState ||
                    current is OptionChangeState,
                builder: (context, state) => CustomTabView(
                  itemCount: bloc.selectedSurveyFormSections.length,
                  onPositionChange: (value) => bloc.add(GetQuestionsForSection(
                      sectionUuId:
                          bloc.selectedSurveyFormSections[value].uuid)),
                  tabBuilder: (context, index) => DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: Tab(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Text(bloc.selectedSurveyFormSections[index].name),
                    )),
                  ),
                  pageBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: bloc.selectedSurveyFormSections[index].uuid ==
                            bloc.lastSelectedSectionUuid
                        ? Stack(
                            children: [
                              DynamicQuestionsView(
                                name: 'survey',
                                questions: bloc.questionAnswers,
                                onImageUpload: (questionUuid, path, isIssue,index) {
                                  bloc.add(UploadImageEvent(
                                      questionUuid, path, isIssue));
                                },
                                onAnswerUpdate:
                                    (String question, String answer,int questionOrder) {
                                  bloc.add(AnswerUpdatedSurveyEvent(
                                      question, answer));
                                },
                              ),
                              BlocBuilder<SurveyBloc, SurveyState>(
                                builder: (context, state) =>
                                    (state is SurveyListLoadingState)
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
            bloc.formEditting == true && bloc.selectedSurvey?.editable == false
                ? const SizedBox()
                : Align(
                    child: InkWell(
                    onTap: bloc.state is SavingAnswersLoadingState
                        ? null
                        : () => bloc.add(SaveSurveyAnswersEvent()),
                    child: Container(
                        width: 1.sw,
                        height: 50.h,
                        alignment: Alignment.center,
                        decoration:
                            const BoxDecoration(color: Color(0xff333333)),
                        child: Text(
                          context.select((SurveyBloc bloc) =>
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

  Future<bool?> _showQuitWarning(BuildContext context, SurveyBloc bloc) {
    return showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text("Are you sure you want to quit Survey"),
            cancelButton: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.red),
                )),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes')),
            ],
          );
        });
  }
}
