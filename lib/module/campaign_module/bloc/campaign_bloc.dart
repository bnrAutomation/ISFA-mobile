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
  final CampaignRepository repo;
  List<AllCampaignModel> storeCampaigns = [];
  List<CampaignQuestionSectionModel> selectedCampSections = [];
  AllCampaignModel? selectedCampaign;
  SavedCampaignDataModel? savedCampaignDetails;
  var selectedPieChartPortionId = -1;
  var lastSelectedSectionUuid = '';

  List<QuestionModel> questionAnswers = [];

  CampaignBloc(this.repo) : super(CampaignInitial()) {
    on((GetStoreCampaignsEvent event, emit) async {
      emit(CampaignListLoadingState());
      storeCampaigns = await repo.getCampaignsForStore();
      emit(CampaignListLoadedState());
    });

    on((GetSavedCampaignResponseEvent event, emit) async {
      final response = await repo
          .savedCampaignResponse(event.campaignId)
          // ignore: invalid_return_type_for_catch_error
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
      // add(GetSavedCampaignResponseEvent(event.id));
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
      questionAnswers = questions.map((e) => e.toViewQuestionModel()).toList();
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
      } else {
        final answers = {
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
                              "questionDataType": question.questionInputType,
                              "answer": question.answer
                            })
                        .toList(),
                  })
              .toList()
        };
        emit(SavingAnswersLoadingState());
        final score =
            await repo.saveCampaignAnswers(answers).catchError((error) {
          emit(ScoreCalculatedCampaignState());
          return false;
        });
        emit(ScoreCalculatedCampaignState());
        if (score) {
          add(GetSavedCampaignResponseEvent(
              questionAnswers.first.campQuestionModel!.uuid));
          emit(SnackbarMessageCampaignState("Saved Successfully"));
        }
      }
    });
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

  List<CampaignQuestionModel> _totalNotAnsweredQuestions() {
    return selectedCampSections
        .map((e) => e.selectedSectionQuestions)
        .expand((element) => element)
        .where((element) =>
            element.isInputMandatory &&
            (element.answer?.trim().isEmpty ?? true))
        .toList();
  }
}
