import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/campaign_module/campaign_repository.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';
import 'package:i_densfa/module/campaign_module/new_models/question_section.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
part 'campaign_event.dart';
part 'campaign_state.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final repo = CampaignRepository();
  final int storeId;
  List<AllCampaignModel> storeCampaigns = [];
  List<CampaignQuestionSectionModel> selectedCampSections = [];
  AllCampaignModel? selectedCampaign;
  SavedCampaignDataModel? savedCampaignDetails;
  var selectedPieChartPortionId = -1;
  var lastSelectedSectionUuid = '';

  List<QuestionModel> questionAnswers = [];

  CampaignBloc(this.storeId) : super(CampaignInitial()) {
    on(_answerUpdatedEvent);
    on((GetStoreCampaignsEvent event, emit) async {
      emit(CampaignListLoadingState());
      storeCampaigns = await repo.getCampaignsForStore();
      emit(CampaignListLoadedState());
    });

    on((GetSavedCampaignResponseEvent event, emit) async {
      final response = await repo
          .savedCampaignResponse(event.campUuid)
          .catchError((onError) {
        emit(SnackbarMessageCampaignState(onError.toString()));
        throw onError;
      });
      if (response != null) {
        savedCampaignDetails = response;
        emit(CampaignQuestionsLoadedState());
      }
    });

    on((GetCampaignSections event, emit) async {
      add(GetSavedCampaignResponseEvent(event.campUuId));
      selectedCampSections =
          await repo.getSections(campaignUuid: event.campUuId);
      if (selectedCampSections.isNotEmpty) {
        add(GetQuestionsForSection(sectionUuId: selectedCampSections[0].uuid));
      }
    });

    on((GetQuestionsForSection event, emit) async {
      saveAnswersForSelectedSection();

      lastSelectedSectionUuid = event.sectionUuId;

      var questions = selectedCampSections
          .firstWhere((element) => element.uuid == event.sectionUuId)
          .selectedSectionQuestions;

      questionAnswers.clear();
      emit(CampaignQuestionsLoadedState());
      if (questions.isEmpty) {
        questions = await repo.getQuestions(
            campaignUuid: selectedCampaign!.uuid,
            sectionUuid: event.sectionUuId);
        selectedCampSections
            .firstWhere((element) => element.uuid == event.sectionUuId)
            .selectedSectionQuestions = questions;
      }
      _updateQuestionModelWithRule();
      emit(CampaignQuestionsLoadedState());
    });

    on((SaveCampaignAnswersEvent event, emit) async {
      saveAnswersForSelectedSection();
      final notAnsweredQuestions = event.checkLeftAnswer
          ? _totalNotAnsweredQuestions()
          : <CampaignQuestionModel>[];

      if (notAnsweredQuestions.isNotEmpty) {
        emit(SnackbarMessageCampaignState(
            "Please answer for ${notAnsweredQuestions.first.question}"));
        return;
      }
      if (!_checkValidations(emit)) return;
      final answers = _getSubmitRequestBody();
      emit(SavingAnswersLoadingState());
      final score = await repo.saveCampaignAnswers(answers).catchError((error) {
        debugPrint(error);
        emit(ScoreCalculatedCampaignState());
        return false;
      });
      if (score) {
        add(GetSavedCampaignResponseEvent(selectedCampaign!.uuid));
        emit(SnackbarMessageCampaignState("Saved Successfully"));
        emit(ScoreCalculatedCampaignState());
      }
    });
  }

  Map<String, Object> _getSubmitRequestBody() {
    return {
      "storeId": storeId,
      "campaignUuid": selectedCampaign!.uuid,
      "campaignResponse": selectedCampSections
          .map((section) => {
                "sectionName": section.name,
                "sectionUuid": section.uuid,
                "questions": section.selectedSectionQuestions
                    .where((question) =>
                        question.answer?.trim().isNotEmpty ?? false)
                    .map((question) => {
                          "questionName": question.question,
                          "questionUuid": question.uuid,
                          "questionDataType":
                              question.questionInputType.toCampaignStringName(),
                          "answer": question.answer
                        })
                    .toList(),
              })
          .toList()
    };
  }

  bool _checkValidations(Emitter<CampaignState> emit) {
    for (final q in _allQuestions()) {
      if (q.inputTypeValidation == 'email') {
        final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(q.answer ?? '');
        if (!emailValid) {
          emit(SnackbarMessageCampaignState(
              "Please enter valid email for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'url') {
        const regex =
            r"^(?:http|https):\/\/[\w\-_]+(?:\.[\w\-_]+)+[\w\-.,@?^=%&:/~\\+#]*$";
        final bool validURl = RegExp(regex).hasMatch(q.answer ?? '');
        if (!validURl) {
          emit(SnackbarMessageCampaignState(
              "Please enter valid URL for ${q.question}"));
          return false;
        }
      }
    }
    return true;
  }

  void saveAnswersForSelectedSection() {
    var lastSelectedQuestions = selectedCampSections
        .firstWhereOrNull((element) => element.uuid == lastSelectedSectionUuid)
        ?.selectedSectionQuestions;

    for (final q in questionAnswers) {
      lastSelectedQuestions
          ?.firstWhereOrNull((element) => element.question == q.question)
          ?.answer = q.answer;
    }
  }

  List<CampaignQuestionModel> _allQuestions() {
    return selectedCampSections
        .map((e) => e.selectedSectionQuestions)
        .expand((element) => element)
        .toList();
  }

  List<CampaignQuestionModel> _totalNotAnsweredQuestions() {
    var lastSelectedQuestions = _allQuestions();
    List<CampaignQuestionModel> newquestionsList = [];
    for (var question in lastSelectedQuestions) {
      if (question.rules.isEmpty) {
        newquestionsList.add(question);
      } else {
        final rule = question.rules.first;
        final compareQuestion = lastSelectedQuestions
            .firstWhereOrNull((q) => q.uuid == rule.questionUuid);
        if (compareQuestion?.answer?.toLowerCase() ==
            rule.answer.toLowerCase()) {
          newquestionsList.add(question);
        }
      }
    }

    return newquestionsList
        .where((element) =>
            element.isInputMandatory &&
            (element.answer?.trim().isEmpty ?? true))
        .toList();
  }

  void _answerUpdatedEvent(AnswerUpdatedCampaignEvent event, emit) {
    saveAnswersForSelectedSection();
    _updateQuestionModelWithRule();
    emit(CampaignQuestionsLoadedState());
  }

  void _updateQuestionModelWithRule() {
    var lastSelectedQuestions = selectedCampSections
        .firstWhereOrNull((element) => element.uuid == lastSelectedSectionUuid)
        ?.selectedSectionQuestions;
    if (lastSelectedQuestions == null) return;
    List<QuestionModel> newquestionsList = [];
    for (var question in lastSelectedQuestions) {
      if (question.rules.isEmpty) {
        newquestionsList.add(question.toViewQuestionModel());
      } else {
        final rule = question.rules.first;
        final compareQuestion = lastSelectedQuestions
            .firstWhereOrNull((q) => q.uuid == rule.questionUuid);
        if (compareQuestion?.answer?.toLowerCase() ==
            rule.answer.toLowerCase()) {
          newquestionsList.add(question.toViewQuestionModel());
        }
      }
      questionAnswers = newquestionsList;
    }
  }
}
