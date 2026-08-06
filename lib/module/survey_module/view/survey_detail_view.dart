import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/survey_module/bloc/survey_bloc.dart';
import 'package:i_densfa/module/survey_module/models/filled_survey_response_model.dart';
import 'package:i_densfa/module/survey_module/view/filter_question_respose.dart';
import 'package:i_densfa/module/survey_module/view/survey_notes_view.dart';
import 'package:i_densfa/module/ui/app_pop_view.dart';
import 'package:i_densfa/module/ui/custom_button.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:searchfield/searchfield.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'survey_schedule_visit_view.dart';

class SelectedSurveyView extends StatelessWidget {
  const SelectedSurveyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SurveyBloc, SurveyState>(
      listener: (context, state) {
        if (state is SnackbarMessageSurveyState) {
          context.showSnackBarMessage(state.message);
        }
        if (state is SurveyNavigateState) {
          final SurveyBloc bloc = context.read();
          context.pushNamed(state.named, extra: bloc).then((value) {
            bloc.add(GetFilledSurveysEvent(
                surveyUuid: bloc.selectedSurvey?.uuid ?? ""));
          });
        }
      },
      builder: (context, state) {
        final SurveyBloc bloc = context.read();
        final selectedSurvey = bloc.selectedSurvey;
        return Scaffold(
          backgroundColor: const Color(0xffBFD1DF),
          floatingActionButton: _floatingButton(context),
          appBar: AppBar(title: Text(selectedSurvey?.name ?? "")),
          body: RefreshIndicator(
            onRefresh: () async {
              // Trigger refresh events
              bloc.add(GetFilledSurveysEvent(
                  surveyUuid: bloc.selectedSurvey?.uuid ?? ""));
              bloc.add(ChangeStateEvent());
              
              // Wait a bit for the data to load
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              controller: bloc.controller,
              padding: const EdgeInsets.all(8.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _userCard(),
                  if (selectedSurvey != null &&
                      selectedSurvey.isNagative() == false)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FilledButton(
                          onPressed: () => {
                                if (AppStorage()
                                        .userDetail
                                        ?.configuration
                                        .requiredClientNameForSurvey ==
                                    true)
                                  {
                                    AppPopup.showAppBottomSheet(
                                      context: context,
                                      child: BlocProvider.value(
                                        value: context.read<SurveyBloc>(),
                                        child: const AddClientNameDialog(),
                                      ),
                                    )
                                  }
                                else
                                  {
                                    bloc.add(SurveyClientNameAdded(
                                        name: AppStorage()
                                                .userDetail
                                                ?.companyName ??
                                            "",
                                        clientfile: null)),
                                    bloc.add(CompleteSurveyFormEvent(
                                      editPrevious: false,
                                    )),
                                  }
                              },
                          style: TextButton.styleFrom(
                            elevation: 2,
                            alignment: Alignment.center,
                            backgroundColor: theme.primaryColor,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Text('Enter Questionnaire',
                                style: GoogleFonts.inter(
                                    fontSize: 14.sp, color: Colors.white)),
                          )),
                    ),
                  _recentNotesCard(context),
                  _scheduledVisits(context),
                  const AddedSurveyViews(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _scheduledVisits(BuildContext context) {
    final nowDate = DateTime.now();
    final bloc = context.read<SurveyBloc>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: const Center(
                child: Text(
                  "Scheduled Visits",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 20),
                ),
              ),
            ),
            ListTile(
              leading: bloc.schedileListDate.isAfter(nowDate)
                  ? IconButton(
                      onPressed: () {
                        if (context.mounted) {
                          final nextdate = bloc.schedileListDate
                              .add(const Duration(days: -1));
                          bloc.add(SurveyVisitsDateChangeEvent(date: nextdate));
                        }
                      },
                      icon: Icon(
                        Icons.chevron_left,
                        color: bloc.schedileListDate.isSameDate(nowDate)
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ))
                  : const SizedBox(),
              trailing: IconButton(
                  onPressed: () {
                    if (context.mounted) {
                      final nextdate =
                          bloc.schedileListDate.add(const Duration(days: 1));
                      bloc.add(SurveyVisitsDateChangeEvent(date: nextdate));
                    }
                  },
                  icon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).primaryColor,
                  )),
              title: TextButton(
                  onPressed: () async {
                    var now = DateTime.now();
                    if (now.weekday == DateTime.sunday) {
                      now = now.add(const Duration(days: 1));
                    }
                    final date = await showDatePicker(
                        selectableDayPredicate: (date) =>
                            date.weekday != DateTime.sunday,
                        context: context,
                        initialDate: now,
                        firstDate: now,
                        lastDate: DateTime(now.year, 12, 31));
                    if (date != null) {
                      if (context.mounted) {
                        bloc.add(SurveyVisitsDateChangeEvent(date: date));
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      foregroundColor: Theme.of(context).primaryColor),
                  child: Text(
                      bloc.schedileListDate.toStringFormat('dd MMM yyyy'))),
            ),
            if (bloc.scheduledVisits.isEmpty)
              SizedBox(
                  width: 1.sw,
                  height: 100,
                  child: const Center(child: Text("No Visit Scheduled")))
            else
              ListView.separated(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bloc.scheduledVisits.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) => Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              bloc.scheduledVisits[index].clientName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              flex: 6,
                              child: Text(bloc.scheduledVisits[index].agenda))
                        ],
                      ))
          ],
        ),
      ),
    );
  }

  Widget _userCard() {
    final user = AppStorage().userDetail;
    if (user == null) {
      return const SizedBox();
    }
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25.w,
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(110),
            child: CachedNetworkImage(
              imageUrl: user.photoUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl: ImageConstants.placeholderUserUrl),
            ),
          ),
        ),
        title: Text(user.username),
        subtitle: Text(user.reportTo),
      ),
    );
  }

  Widget _floatingButton(BuildContext context) {
    return SpeedDial(
      closedForegroundColor: Colors.white,
      closedBackgroundColor: Theme.of(context).primaryColor,
      openForegroundColor: Theme.of(context).primaryColor,
      openBackgroundColor: Colors.white,
      speedDialChildren: [
        SpeedDialChild(
          child: const Icon(Icons.note_add),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Add a Note',
          onPressed: () {
            showCupertinoDialog(
                context: context,
                builder: (c) => BlocProvider.value(
                    value: context.read<SurveyBloc>(),
                    child: const AddNoteDialogueView()));
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.pending_actions),
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          label: 'Schedule Visit',
          onPressed: () {
            final bloc = context.read<SurveyBloc>();
            if (bloc.surveyClientList.isEmpty) {
              context.showSnackBarMessage("Client names not found!");
              return;
            }
            Navigator.of(context).push(MaterialPageRoute(
                builder: (c) => BlocProvider.value(
                    value: bloc, child: const SurveyScheduleVisitView())));
          },
        ),
      ],
      child: Icon(Icons.add, size: 30.w),
    );
  }

  Widget _recentNotesCard(BuildContext context) {
    return InkWell(
      onTap: () {
        AppPopup.showAppBottomSheet(
            context: context,
            child: BlocProvider.value(
              value: context.read<SurveyBloc>(),
              child: const SurveyNotesView(),
            ));
      },
      child: Card(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(ImageConstants.notesT),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Recent Notes (${context.read<SurveyBloc>().surveyNotesList.length})',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                    Text('Notes of important discussion with the sub dealer',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              SvgPicture.asset(
                ImageConstants.paperPen,
                width: 60.w,
                height: 50.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AddClientNameDialog extends StatefulWidget {
  const AddClientNameDialog({super.key});

  @override
  State<AddClientNameDialog> createState() => _AddClientNameDialogState();
}

class _AddClientNameDialogState extends State<AddClientNameDialog> {
  final nameTextEditingController = TextEditingController();
  XFile? image;
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SurveyBloc>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 5),
              Text(
                "Add Retailer",
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text("Retailer Name", style: textTheme.labelLarge),
              const SizedBox(height: 5),
              SearchField(
                controller: nameTextEditingController,
                suggestions: bloc.surveyClientList
                    .map((e) => SearchFieldListItem(e,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              e,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )))
                    .toList(),
              ),
              const SizedBox(height: 10),
              AppStorage().userDetail?.configuration.requiredSelfieForSurvey ==
                      true
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Text(
                        "Add your Selfie",
                        textAlign: TextAlign.center,
                        style: textTheme.labelLarge,
                      ),
                    )
                  : const SizedBox(),
              AppStorage().userDetail?.configuration.requiredSelfieForSurvey ==
                      true
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                              width: 0.5.sp,
                            )),
                        width: 1.sw,
                        height: 0.4.sw,
                        child: InkWell(
                          onTap: () async {
                            image = await ImagePicker().pickImage(
                                source: kReleaseMode
                                    ? ImageSource.camera
                                    : ImageSource.gallery);
                            setState(() {});
                          },
                          child: Center(
                            child: image == null
                                ? const Text(
                                    'Include the surroundings and avoid glare.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(),
                                  )
                                : Image.file(File(image!.path)),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
              CustomButton(
                  buttonText: "continue",
                  onPressed: () {
                    if (nameTextEditingController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please Enter Retailer Name.'),
                        ),
                      );

                      return;
                    }

                    if (AppStorage()
                            .userDetail
                            ?.configuration
                            .requiredSelfieForSurvey ==
                        true) {
                      if (image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mandatory to add image.'),
                          ),
                        );
                        return;
                      }
                    }

                    bloc.add(SurveyClientNameAdded(
                        name: nameTextEditingController.text,
                        clientfile: image));
                    bloc.add(CompleteSurveyFormEvent(
                      editPrevious: false,
                    ));
                    Navigator.pop(context);
                  },
                  isLoading: false,
                  isSuccess: false)
            ]))

        //  AlertDialog(
        //   title: const Text("Add Client Name"),
        //   content: EasyAutocomplete(
        //     // inputFormatters: [
        //     //   FilteringTextInputFormatter.deny(RegExp('(’|‘|”|“||<|>|)')),
        //     // ],
        //     controller: nameTextEditingController,
        //     decoration: const InputDecoration(
        //         hintText: 'Please enter...', border: OutlineInputBorder()),
        //     suggestions: bloc.surveyClientList,
        //   ),
        //   actions: [

        //     MaterialButton(
        //         padding: EdgeInsets.zero,
        //         onPressed: () {
        //           Navigator.pop(context);
        //         },
        //         child: const Text(
        //           "Cancel",
        //           style: TextStyle(color: Colors.red),
        //         ))
        //   ],
        // ),

        );
  }
}

class AddedSurveyViews extends StatefulWidget {
  const AddedSurveyViews({super.key});

  @override
  State<AddedSurveyViews> createState() => _AddedSurveyViewsState();
}

class _AddedSurveyViewsState extends State<AddedSurveyViews> {
  final searchTextEditController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SurveyBloc>();

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: SearchBar(
                        leading: const Icon(Icons.search, color: Colors.black),
                        hintText: 'Search by name...',
                        side: WidgetStateProperty.all(
                            const BorderSide(width: 1.0, color: Colors.black)),
                        controller: searchTextEditController,
                        elevation: WidgetStateProperty.all(0.0),
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                        onChanged: (value) =>
                            bloc.add(SurveyListSearchEvent(seachText: value))),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    AppPopup.showAppBottomSheet(
                        context: context,
                        child: BlocProvider.value(
                          value: context.read<SurveyBloc>(),
                          child: const FilterQuestionRespnseView(),
                        )).then((value) => {bloc.add(ChangeStateEvent())});
                  },
                  icon: const Icon(Icons.filter_list),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: BlocBuilder<SurveyBloc, SurveyState>(
                builder: (context, state) {
                  final questionIds = bloc
                          .response?.surveyResponse.dynamicAttribute
                          ?.split(",") ??
                      [];

                  if (bloc.response?.surveyResponse == null) {
                    return const SizedBox();
                  }
                  if (questionIds.isEmpty || questionIds.first.isEmpty) {
                    questionIds.clear();
                  }
                  return DataTable(
                    showCheckboxColumn: false,
                    columns: [
                      const DataColumn(label: Text("Client Name")),
                      const DataColumn(label: Text("Date")),
                      // const DataColumn(label: Text("Status")),
                      if (questionIds.isNotEmpty)
                        ...questionIds.map((e) =>
                            const DataColumn(label: Text("Question/Answer")))
                    ],
                    rows: [
                      ...bloc.filledSurveyUserResponse.map(
                        (response) => DataRow(
                            onSelectChanged: (value) {
                              bloc.selectedSurveyUserResponse = response;
                              bloc.add(SurveyClientNameAdded(
                                  name: response.clientName));
                              bloc.add(
                                  CompleteSurveyFormEvent(editPrevious: true));
                            },
                            selected: true,
                            cells: [
                              DataCell(Text(response.clientName)),
                              DataCell(Text(response.createdDate
                                  .toStringFormat("dd/MM/yyyy"))),
                              if (questionIds.isNotEmpty)
                                ...questionIds.map((questionUuid) {
                                  var question =
                                      response.questionResponse.firstWhere(
                                    (question) =>
                                        question.questionUuid == questionUuid,
                                    orElse: () {
                                      return FilledSurveyQuestionResponse(
                                          questionName: "",
                                          questionUuid: "",
                                          answer: "",
                                          isActive: false);
                                    },
                                  );

                                  return question.questionName.isEmpty
                                      ? const DataCell(Text("Not Available"))
                                      : DataCell(Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(question.questionName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(question.answer)
                                          ],
                                        ));
                                })
                            ]),
                      ),
                    ],
                  );
                },
              )),
          Visibility(
              visible: bloc.isloadingNext, child: const Text("Loading....")),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
