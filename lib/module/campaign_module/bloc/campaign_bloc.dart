import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/campaign_module/campaign_repository.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';

part 'campaign_event.dart';
part 'campaign_state.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final CampaignRepository repo;
  List<CampaignDetailModel> storeCampaigns = [];
  CampaignDetailModel? selectedCampaign;
  List<CampQuestionModel> selectedAssessQuestions = [];
  var selectedPieChartPortionId = -1;

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
        selectedCampaign?.campaignData = response;
        emit(CampaignQuestionsLoadedState());
      }
    });

    on((GetQuestionsForCampaign event, emit) async {
      selectedCampaign = storeCampaigns
          .firstWhere((element) => element.campaignId == event.id);
      add(GetSavedCampaignResponseEvent(event.id));
      selectedAssessQuestions = await repo.getQuestions(event.id);
      questionAnswers =
          selectedAssessQuestions.map((e) => e.toViewQuestionModel()).toList();
      emit(CampaignQuestionsLoadedState());
    });

    on((SaveCampaignAnswersEvent event, emit) async {
      final notAnsweredQuestions = event.checkLeftAnswer
          ? questionAnswers
              .where((element) => element.isRequired && element.answer == null)
              .toList()
          : [];
      if (notAnsweredQuestions.isNotEmpty) {
        emit(SnackbarMessageCampaignState(
            "Please answer for ${notAnsweredQuestions.first.question}"));
      } else {
        final answers = questionAnswers
            .where((element) => element.answer?.isNotEmpty ?? false)
            .map((e) => e.toCampaignRequest())
            .toList();
        emit(SavingAnswersLoadingState());
        final score =
            await repo.saveCampaignAnswers(answers).catchError((error) {
          emit(ScoreCalculatedCampaignState());
          return false;
        });
        emit(ScoreCalculatedCampaignState());
        if (score) {
          add(GetSavedCampaignResponseEvent(
              questionAnswers.first.campQuestionModel!.campaignId));
          emit(SnackbarMessageCampaignState("Saved Successfully"));
        }
      }
    });
  }
}
