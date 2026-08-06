import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/survey_module/bloc/survey_bloc.dart';
import 'package:i_densfa/module/survey_module/models/filled_survey_response_model.dart';

class FilterQuestionRespnseView extends StatelessWidget {
  const FilterQuestionRespnseView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 1.sw,
                ),
                Text(
                  "Filter",
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocBuilder<SurveyBloc, SurveyState>(
                    builder: (BuildContext context, SurveyState state) {
                      final bloc = context.read<SurveyBloc>();
                      List<String> questionIds = bloc
                              .response?.surveyResponse.dynamicAttribute
                              ?.split(",") ??
                          [];
                      if (bloc.filledSurveyUserResponse.isEmpty) {
                        return const Center(child: Text("No Filter Options"));
                      }

                      List<FilledSurveyQuestionResponse> questionResponse =
                          bloc.filledSurveyUserResponse.getfilterQuestion();

                      return ListView.separated(
                          itemCount: questionResponse.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) => ColoredBox(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1),
                                child: ListTile(
                                  tileColor: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.2),
                                  title: Row(
                                    children: [
                                      Checkbox(
                                          value:
                                              questionResponse[index].isActive,
                                          onChanged: (value) => {
                                                questionIds.remove(
                                                    questionResponse[index]
                                                        .questionUuid),
                                                if (value == true)
                                                  {
                                                    questionIds.add(
                                                        questionResponse[index]
                                                            .questionUuid)
                                                  },
                                                bloc.response?.surveyResponse
                                                        .dynamicAttribute =
                                                    bloc.getIdList(questionIds),
                                                questionResponse[index]
                                                        .isActive =
                                                    !questionResponse[index]
                                                        .isActive,
                                                bloc.add(ChangeStateEvent())
                                              }),
                                      Expanded(
                                        child: Text(
                                          questionResponse[index].questionName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                    },
                  ),
                )
              ],
            )));
  }
}
