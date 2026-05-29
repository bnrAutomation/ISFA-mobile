import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:i_densfa/module/campaign_module/bloc/campaign_bloc.dart';
import 'package:i_densfa/module/dynamic_questions_module/views/dynamic_questions_view.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/custom_tab_view.dart';

class CampaignQuestionsView extends StatefulWidget {
  const CampaignQuestionsView({super.key});
  @override
  State<CampaignQuestionsView> createState() => _CampaignQuestionsViewState();
}

class _CampaignQuestionsViewState extends State<CampaignQuestionsView> {
  @override
  Widget build(BuildContext context) {
    final CampaignBloc bloc = context.read();
    bool isDialogShowing = false;
    return PopScope(
        canPop: bloc.canpopshow,
        onPopInvokedWithResult: (value, result) async {
          if (!bloc.canpopshow) {
            if (isDialogShowing) return;
            isDialogShowing = true;
            final response = await _showQuitWarning(context, bloc);
            if (response == true && context.mounted) {
              Navigator.pop(context);
            }
            isDialogShowing = false;
          }
        },
        child: Scaffold(
          appBar:
              AppBar(title: Text(bloc.selectedCampaign?.name ?? "Campaign")),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BlocConsumer<CampaignBloc, CampaignState>(
                    listener: (context, state) {
                      if (state is ScoreCalculatedCampaignState) {
                        bloc.questionAnswers.clear();
                        if (bloc.from == AppPaths.tabbar) {
                          Navigator.pop(context);
                        } else {
                          Navigator.popUntil(
                              context, ModalRoute.withName(bloc.from));
                        }
                      }
                      if (state is OfflineSubmissionQueuedState) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Campaign saved offline. ${state.totalPending} pending submission(s)."),
                          action: SnackBarAction(
                            label: 'Sync Now',
                            onPressed: () {
                              bloc.add(SyncOfflineSubmissionsEvent());
                            },
                          ),
                        ));
                      }
                      if (state is SyncingOfflineDataState) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Syncing ${state.pendingCount} submission(s)...")));
                      }
                      if (state is SagmentAddSuccessfully) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("New Segment added")));
                      }
                      if (state is SnackbarMessageCampaignState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)));
                      }
                    },
                    buildWhen: (previous, current) =>
                        current is CampaignQuestionsLoadedState ||
                        current is SavingAnswersLoadingState ||
                        current is OptionChangeState,
                    builder: (context, state) {
                      // Guard: no sections yet or campaign not loaded
                      if (bloc.selectedCampSections.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return CustomTabView(
                        itemCount: bloc.selectedCampSections.length,
                        onPositionChange: (value) => bloc.add(
                            GetQuestionsForSection(
                                sectionUuId:
                                    bloc.selectedCampSections[value].uuid)),
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
                              ? Stack(
                                  children: [
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          DynamicQuestionsView(
                                            name:
                                                "${bloc.selectedCampaign?.name}",
                                            questions: bloc.questionAnswers,
                                            onImageUpload: (questionUuid, path,
                                                isIssue, index) {
                                              bloc.add(UploadImageEvent(
                                                  questionUuid,
                                                  path,
                                                  isIssue,
                                                  index,
                                                  -1));
                                            },
                                            onAnswerUpdate: (String question,
                                                String answer,
                                                int questionOrder) {
                                              bloc.add(
                                                  AnswerUpdatedCampaignEvent(
                                                      question,
                                                      bloc
                                                          .selectedCampSections[
                                                              index]
                                                          .name,
                                                      -1,
                                                      questionOrder));
                                            },
                                          ),
                                          if ([
                                            "osmm",
                                            "isp",
                                            "record sales",
                                            "stock",
                                            'demo audit',
                                             'vm demo audit',
                                            'fixture audit',
                                            'vm fixture audit',
                                          ].contains(bloc
                                              .selectedCampSections[index].name
                                              .toLowerCase()))
                                            for (int i = 0;
                                                i < bloc.segmentList.length;
                                                i++)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2),
                                                color: Colors.grey.shade200,
                                                child: Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: IconButton(
                                                          onPressed: () => {
                                                                bloc.segmentList
                                                                    .removeAt(
                                                                        i),
                                                                bloc.add(
                                                                    ChangeStateEvent())
                                                              },
                                                          icon: const Icon(
                                                              Icons.dangerous)),
                                                    ),
                                                    DynamicQuestionsView(
                                                      name:
                                                          "${bloc.selectedCampaign?.name}",
                                                      questions: bloc
                                                          .segmentList[i]
                                                          .questionAnswers,
                                                      onImageUpload:
                                                          (questionUuid, path,
                                                              isIssue, index) {
                                                        bloc.add(
                                                            UploadImageEvent(
                                                                questionUuid,
                                                                path,
                                                                isIssue,
                                                                index,
                                                                i));
                                                      },
                                                      onAnswerUpdate: (String
                                                              question,
                                                          String answer,
                                                          int questionOrder) {
                                                        bloc.add(AnswerUpdatedCampaignEvent(
                                                            question,
                                                            bloc
                                                                .selectedCampSections[
                                                                    index]
                                                                .name
                                                                .toLowerCase(),
                                                            i,
                                                            questionOrder));
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          if (bloc.selectedCampSections[index]
                                                      .name
                                                      .toLowerCase() ==
                                                  "osmm" &&
                                              bloc.questionAnswers.isNotEmpty)
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                    iconColor: Colors.black,
                                                    backgroundColor:
                                                        Colors.amber,
                                                    textStyle: const TextStyle(
                                                        color: Colors.black)),
                                                icon: const Icon(Icons.add),
                                                onPressed: () => {
                                                  bloc.add(AddSagmentEvent(
                                                      bloc.questionAnswers))
                                                },
                                                label: const FittedBox(
                                                  child: Text("Add Mechanic",
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                            ),
                                          if (bloc.selectedCampSections[index]
                                                      .name
                                                      .toLowerCase() ==
                                                  "record sales" &&
                                              bloc.questionAnswers.isNotEmpty)
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                    iconColor: Colors.black,
                                                    backgroundColor:
                                                        Colors.amber,
                                                    textStyle: const TextStyle(
                                                        color: Colors.black)),
                                                icon: const Icon(Icons.add),
                                                onPressed: () => {
                                                  bloc.add(AddQtySagmentEvent(
                                                      bloc.questionAnswers))
                                                },
                                                label: const FittedBox(
                                                  child: Text("Add More",
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                            ),
                                          if ([
                                                'stock',
                                                'demo audit',
                                                 'vm demo audit',
                                                'fixture audit',
                                                 'vm fixture audit'
                                              ].contains(bloc
                                                  .selectedCampSections[index]
                                                  .name
                                                  .toLowerCase()) &&
                                              bloc.questionAnswers.isNotEmpty)
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                    iconColor: Colors.black,
                                                    backgroundColor:
                                                        Colors.amber,
                                                    textStyle: const TextStyle(
                                                        color: Colors.black)),
                                                icon: const Icon(Icons.add),
                                                onPressed: () => {
                                                  if (bloc
                                                          .selectedCampSections[
                                                              index]
                                                          .name
                                                          .toLowerCase() ==
                                                      'stock')
                                                    {
                                                      bloc.add(AddStockEvent(
                                                          bloc.questionAnswers))
                                                    }
                                                  else if (bloc
                                                          .selectedCampSections[
                                                              index]
                                                          .name
                                                          .toLowerCase() ==
                                                      'demo audit'|| bloc
                                                          .selectedCampSections[
                                                              index]
                                                          .name
                                                          .toLowerCase() ==
                                                      'vm demo audit')
                                                    {
                                                       bloc.add(AddDemoAuditEvent(
                                                          bloc.questionAnswers))
                                                    }else if(bloc.selectedCampSections[index].name.toLowerCase() == 'fixture audit' || bloc.selectedCampSections[index].name.toLowerCase() == 'vm fixture audit'){
                                                      bloc.add(AddFixtureAuditEvent(
                                                          bloc.questionAnswers))
                                                    }
                                                },
                                                label: const FittedBox(
                                                  child: Text("Add More",
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                              ),
                                            ),
                                          if (bloc.selectedCampSections[index]
                                                      .name
                                                      .toLowerCase() ==
                                                  "isp" &&
                                              bloc.questionAnswers.isNotEmpty)
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            iconColor:
                                                                Colors.black,
                                                            backgroundColor:
                                                                Colors.amber,
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                    icon: const Icon(Icons.add),
                                                    onPressed: () => {
                                                      bloc.add(
                                                          AddProductSagmentEvent(
                                                              bloc.questionAnswers))
                                                    },
                                                    label: const FittedBox(
                                                      child: Text("Add Product",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                  ),
                                                ),
                                                // const SizedBox(
                                                //     width:
                                                //         3), // space between buttons
                                                // Expanded(
                                                //   child: ElevatedButton.icon(
                                                //     style: ElevatedButton
                                                //         .styleFrom(
                                                //             iconColor:
                                                //                 Colors.black,
                                                //             backgroundColor:
                                                //                 Colors.amber,
                                                //             textStyle:
                                                //                 const TextStyle(
                                                //                     color: Colors
                                                //                         .black)),
                                                //     icon: const Icon(Icons.add),
                                                //     onPressed: () => {
                                                //       bloc.add(
                                                //           AddGiftSagmentEvent(bloc
                                                //               .questionAnswers))
                                                //     },
                                                //     label: const FittedBox(
                                                //       child: Text("Add Gift",
                                                //           style: TextStyle(
                                                //               color: Colors
                                                //                   .black)),
                                                //     ),
                                                //   ),
                                                // ),
                                                const SizedBox(
                                                    width:
                                                        3), // space between buttons
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            iconColor:
                                                                Colors.black,
                                                            backgroundColor:
                                                                Colors.amber,
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                    icon: const Icon(Icons.add),
                                                    onPressed: () => {
                                                      bloc.add(
                                                          AddAnotherSoldSagmentEvent(
                                                              bloc.questionAnswers))
                                                    },
                                                    label: const FittedBox(
                                                      child: Text(
                                                          "End Activity",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(height: 10)
                                        ],
                                      ),
                                    ),
                                    BlocBuilder<CampaignBloc, CampaignState>(
                                      builder: (context, state) =>
                                          (state is CampaignListLoadingState)
                                              ? const Positioned.fill(
                                                  child: ColoredBox(
                                                      color: Colors.white10,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
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
                      );
                    },
                  ),
                ),
                Align(
                    child: InkWell(
                  onTap: bloc.isloading
                      // bloc.state is SavingAnswersLoadingState
                      ? null
                      : () => bloc.add(SaveCampaignAnswersEvent(true)),
                  child: Container(
                      width: 1.sw,
                      height: 50.h,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xff333333)),
                      child: Text(
                        context.select((CampaignBloc bloc) => bloc.isloading
                            // bloc.state is SavingAnswersLoadingState
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
        ));
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
