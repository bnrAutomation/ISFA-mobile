import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/campaign_module/bloc/campaign_bloc.dart';
import 'package:i_densfa/module/dynamic_questions_module/views/dynamic_questions_view.dart';
import 'package:i_densfa/utility/custom_tab_view.dart';

class CampaignQuestionsView extends StatelessWidget {
  const CampaignQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final CampaignBloc bloc = context.read();

    return WillPopScope(
      onWillPop: () async {
        final response = await _showQuitWarning(context, bloc);
        if (response == true) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(bloc.selectedCampaign?.name ?? "Campaign")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BlocConsumer<CampaignBloc, CampaignState>(
                listener: (context, state) {
                  if (state is ScoreCalculatedCampaignState) {
                    bloc.questionAnswers.clear();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                buildWhen: (previous, current) =>
                    current is CampaignQuestionsLoadedState ||
                    current is SavingAnswersLoadingState,
                builder: (context, state) => CustomTabView(
                  itemCount: bloc.selectedCampSections.length,
                  onPositionChange: (value) => bloc.add(GetQuestionsForSection(
                      sectionUuId: bloc.selectedCampSections[value].uuid)),
                  tabBuilder: (context, index) => DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: Tab(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Text(bloc.selectedCampSections[index].name),
                    )),
                  ),
                  pageBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: bloc.selectedCampSections[index].uuid ==
                            bloc.lastSelectedSectionUuid
                        ? DynamicQuestionsView(
                            questions: bloc.questionAnswers,
                            onAnswerUpdate: () {
                              bloc.add(AnswerUpdatedCampaignEvent());
                            },
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
                  : () => bloc.add(SaveCampaignAnswersEvent(true)),
              child: Container(
                  width: 1.sw,
                  height: 50.h,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xff333333)),
                  child: Text(
                    context.select((CampaignBloc bloc) =>
                        bloc.state is SavingAnswersLoadingState
                            ? "Loading.."
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

  Future<bool?> _showQuitWarning(BuildContext context, CampaignBloc bloc) {
    return showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text("Are you sure you want to quit Campaign"),
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
