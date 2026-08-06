import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/campaign_module/campaign_repository.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';
import 'package:i_densfa/module/campaign_module/new_models/question_section.dart';
import 'package:i_densfa/module/campaign_module/new_models/response_model.dart';
import 'package:i_densfa/module/campaign_module/services/campaign_offline_service.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:i_densfa/module/dynamic_questions_module/sagment_model.dart';
import 'package:i_densfa/module/dynamic_questions_module/sagment_request.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/continuous_location_service.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/services/global_offline_sync_service.dart';
part 'campaign_event.dart';
part 'campaign_state.dart';

// Wrapper for Emitter to use in sync handler
// We can't properly implement Emitter interface, so we'll use a different approach
class EmitterWrapper {
  void call(CampaignState state) {
    // Handle state emission if needed for background sync
    // In background sync, we don't emit states to avoid UI blocking
  }
}

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  final repo = CampaignRepository();
  late final CampaignOfflineService _offlineService;
  final int storeId;
  final double storeLat;
  final double storeLong;
  List<AllCampaignModel> storeCampaigns = [];
  List<String> filledCampaignList = [];
  bool alreadyVisited = false;
  List<CampaignQuestionSectionModel> allCampSections = [];
  List<CampaignQuestionSectionModel> selectedCampSections = [];
  AllCampaignModel? selectedCampaign;
  SavedCampaignDataModel? savedCampaignDetails;
  var selectedPieChartPortionId = -1;
  var lastSelectedSectionUuid = '';
  List<RecruiterModel> recruiterModelList = [];

  List<QuestionModel> questionAnswers = [];
  List<SegmentModel> segmentList = [];
  List<RecruiterModel> recs = [];
  List<MechanicModel> mechanics = [];
  List<ProductInfo> productInfo = [];

  String from;
  bool canpopshow = false;

  int indexCampaign = -1;
  bool isloading = false;
  String selectedMechanicName="";
  String selectedMechanicContact = "";
  String retailerName="";

  CampaignBloc(this.storeId, this.from, this.storeLat, this.storeLong)
      : super(CampaignInitial()) {
    _offlineService = repo.offlineService;
    // Initialize offline service
    _offlineService.init();

    // Register sync handler with global service
    // Note: We pass null as emitter since background sync doesn't emit states
    GlobalOfflineSyncService.instance.registerSyncHandler(
      SyncDataType.campaign,
      (bool bySync) async {
        // Create a dummy emitter for background sync
        await _syncOfflineSubmissionsBackground(bySync: bySync);
      },
    );

    on(_answerUpdatedEvent);
    on(_uploadImageEvent);
    on<ChangeStateEvent>((event, emit) => emit(OptionChangeState()));
    on((SyncOfflineSubmissionsEvent event, emit) async {
      await _syncOfflineSubmissions(emit, bySync: false); // Manual sync
    });

    on((PreSyncCampaignsForStoreEvent event, emit) async {
      try {
        // Run pre-sync in background - don't block UI
        // User can still navigate while pre-sync happens
        repo.preSyncCampaignsForStore(event.storeId).catchError((e) {
          debugPrint('Pre-sync error: $e');
          // Optionally emit a non-blocking message
          emit(SnackbarMessageCampaignState(
              'Pre-sync completed with some errors. Some data may not be available offline.'));
        });

        // Emit a subtle message to inform user
        emit(SnackbarMessageCampaignState(
            'Pre-syncing campaign data for offline use...'));
      } catch (e) {
        debugPrint('Failed to start pre-sync: $e');
      }
    });
    on((SnackbarMessageCampaignEvent event, emit) =>
        emit(SnackbarMessageCampaignState(event.message)));
    on((GetStoreCampaignsEvent event, emit) async {
      try {
        emit(CampaignListLoadingState());
        storeCampaigns = await repo.getCampaignsForStore(event.storeId);

        if(event.mechanicsName.isEmpty){
        storeCampaigns.removeWhere(
            (campaign) => campaign.name.toLowerCase() == "mechanic visit");
        }
        emit(CampaignListLoadedState());

        // If online, trigger background pre-sync of all campaign data
        final isOnline = await _offlineService.isOnline();
        if (isOnline && storeCampaigns.isNotEmpty) {
          // Run pre-sync in background - don't await, don't block UI
          repo.preSyncCampaignsForStore(event.storeId).catchError((e) {
            debugPrint('Background pre-sync failed: $e');
          });
        }
      } catch (e) {
        emit(SnackbarMessageCampaignState(onError.toString()));
      }
    });

    on((GetFilledCampaignsEvent event, emit) async {
      if (
          // AppStorage().userDetail?.companyName.toLowerCase() != "samsung"
          !(AppStorage().userDetail?.configuration.requiresAllFillCampigned ??
              false)) {
        return;
      }
      try {
        emit(CampaignListLoadingState());
        filledCampaignList = await repo.getFilledCampaign(event.storeId);
        emit(CampaignListLoadedState());
      } catch (e) {
        emit(SnackbarMessageCampaignState(onError.toString()));
      }

      alreadyVisited = await repo.hasStoreBeenVisitedToday(storeId);
      emit(CampaignListLoadedState());
    });

    on((GetSavedCampaignResponseEvent event, emit) async {
      savedCampaignDetails = null;
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

    on((GetCampaignSectionsFirstTime event, emit) async {
      // Start fresh for this campaign – clear any previous dynamic segments
      segmentList.clear();
      indexCampaign = event.index;
      add(GetSavedCampaignResponseEvent(event.campUuId));
      allCampSections =
          await repo.getSections(campaignUuid: event.campUuId);
      allCampSections
          .sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
      _updateVisibleSections(switchSectionIfHidden: false);
      if (selectedCampSections.isNotEmpty) {
        lastSelectedSectionUuid = selectedCampSections.first.uuid;
        add(GetQuestionsForSectionFirstTime(
            sectionUuId: selectedCampSections.first.uuid));
      }
    });

    on((GetCampaignSections event, emit) async {
      // Start fresh when reopening a campaign as well
      segmentList.clear();
      indexCampaign = event.index;
      add(GetSavedCampaignResponseEvent(event.campUuId));
      allCampSections =
          await repo.getSections(campaignUuid: event.campUuId);
      allCampSections
          .sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
      _updateVisibleSections(switchSectionIfHidden: false);
      if (selectedCampSections.isNotEmpty) {
        lastSelectedSectionUuid = selectedCampSections.first.uuid;
        add(GetQuestionsForSection(sectionUuId: selectedCampSections.first.uuid));
      }
    });

    on((GetQuestionsForSectionFirstTime event, emit) async {
      try {
        // Save answers for previously selected section (if any) BEFORE switching.
        saveAnswersForSelectedSection();

        final section = selectedCampSections
            .firstWhereOrNull((element) => element.uuid == event.sectionUuId);
        if (section == null) {
          emit(SnackbarMessageCampaignState(
              'Section not found. Please try again.'));
          emit(CampaignQuestionsLoadedState());
          emit(CampaignQuestionsLoadedForState());
          return;
        }

        // Now switch active section.
        lastSelectedSectionUuid = event.sectionUuId;

        var questions = section.selectedSectionQuestions;
        questionAnswers.clear();
        emit(CampaignQuestionsLoadedState());
        if (questions.isEmpty) {
          emit(CampaignListLoadingState());
          try {
            questions = await repo.getQuestions(
                campaignUuid: selectedCampaign!.uuid,
                sectionUuid: event.sectionUuId);
            // questions = _findValidCampaignQuestion(ques);
          } catch (e) {
            emit(SnackbarMessageCampaignState(
                'No cached questions available for this section. Please go online once to load it.'));
            emit(CampaignQuestionsLoadedState());
            emit(CampaignQuestionsLoadedForState());
            return;
          }

          // Inject mechanic options only when online (or if we already have cached mechanics in memory).
          if (questions.any((element) =>
              element.question.trim().toLowerCase() ==
              "Select Mechanics".toLowerCase())) {
            try {
              final isOnline = await _offlineService.isOnline();
              if (isOnline) {
                mechanics = await repo.getMechanics(selectedMechanicName,selectedMechanicContact);
              }
              final List<String> mecNameList = selectedCampSections.any(
                      (element) =>
                          element.name.toLowerCase() ==
                          "Mechanic Enrollment".toLowerCase())
                  ? mechanics
                      .where((element) => element.isEnrolled == false)
                      .map((mechanic) =>
                          "${mechanic.mechanicName}-${mechanic.mechanicNumber}")
                      .toList()
                  : mechanics
                      .map((mechanic) =>
                          "${mechanic.mechanicName}-${mechanic.mechanicNumber}")
                      .toList();

              if (mecNameList.isNotEmpty) {
                final orion = mecNameList.join(",");
                questions
                    .where((element) =>
                        element.question.trim().toLowerCase() ==
                        "Select Mechanics".toLowerCase())
                    .forEach((element) {
                  element.options = orion;
                });
              }
            } catch (e) {
              // Do not block section switching if mechanics can't be fetched offline.
              debugPrint('Failed to load mechanics: $e');
            }
          }

          // Inject recruiter options only when online (or if already available in memory).
          if (questions.any((element) =>
              element.question.trim().toLowerCase() ==
                  "Retailer/Workshop Name".toLowerCase() ||
              element.question.trim().toLowerCase() ==
                  "Retailer Name".toLowerCase() ||
              element.question.trim().toLowerCase() ==
                  "Select Retailer".toLowerCase() ||
              element.question.trim().toLowerCase() ==
                  "Add Outlet name".toLowerCase())) {
            try {
              final isOnline = await _offlineService.isOnline();
              if (isOnline) {
                recs = await repo.getRecruiters(retailerName,selectedMechanicName,[
      'master data',
     ].contains(selectedCampaign?.name.trim().toLowerCase()));
              }
              if (recs.isNotEmpty) {
                final optionsList = recs.map((e) => e.counterName).toList();
                final onion = optionsList.join(",");
                questions
                    .where((element) =>
                        element.question.trim().toLowerCase() ==
                            "Retailer/Workshop Name".toLowerCase() ||
                        element.question.trim().toLowerCase() ==
                            "Add Outlet name".toLowerCase() ||
                        element.question.trim().toLowerCase() ==
                            "Retailer Name".toLowerCase())
                    .forEach((element) {
                  element.options = onion;
                });
              }
            } catch (e) {
              debugPrint('Failed to load recruiters: $e');
            }
          }

          questions.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
          section.selectedSectionQuestions = questions;
        }

        _updateQuestionModelWithRule();
        emit(CampaignQuestionsLoadedState());
        emit(CampaignQuestionsLoadedForState());
      } catch (e, st) {
        debugPrint('GetQuestionsForSectionFirstTime error: $e');
        debugPrint('$st');
        emit(SnackbarMessageCampaignState(
            'Unable to load this section. Please try again.'));
        emit(CampaignQuestionsLoadedState());
        emit(CampaignQuestionsLoadedForState());
      }
    });

    on((GetQuestionsForSection event, emit) async {
      try {
        // Save answers for previously selected section (if any) BEFORE switching.
        saveAnswersForSelectedSection();

        final section = selectedCampSections
            .firstWhereOrNull((element) => element.uuid == event.sectionUuId);
        if (section == null) {
          emit(SnackbarMessageCampaignState(
              'Section not found. Please try again.'));
          emit(CampaignQuestionsLoadedState());
          return;
        }

        // Now switch active section.
        lastSelectedSectionUuid = event.sectionUuId;
        var questions = section.selectedSectionQuestions;
        questionAnswers.clear();
        emit(CampaignQuestionsLoadedState());
        if (questions.isEmpty) {
          emit(CampaignListLoadingState());
          try {
            questions = await repo.getQuestions(
              campaignUuid: selectedCampaign!.uuid,
              sectionUuid: event.sectionUuId,
            );
          } catch (e) {
            emit(SnackbarMessageCampaignState(
                'No cached questions available for this section. Please go online once to load it.'));
            emit(CampaignQuestionsLoadedState());
            return;
          }
          // Inject mechanic options only when online (or if we already have cached mechanics in memory).
          if (questions.any((element) =>
              element.question.trim().toLowerCase() ==
              "Select Mechanics".toLowerCase())) {
            try {
              final isOnline = await _offlineService.isOnline();
              if (isOnline) {
                mechanics = await repo.getMechanics(selectedMechanicName,selectedMechanicContact);
              }
              final List<String> mecNameList = selectedCampSections.any(
                      (element) =>
                          element.name.toLowerCase() ==
                          "Mechanic Enrollment".toLowerCase())
                  ? mechanics
                      .where((element) => element.isEnrolled == false)
                      .map((mechanic) =>
                          "${mechanic.mechanicName}-${mechanic.mechanicNumber}")
                      .toList()
                  : mechanics
                      .map((mechanic) =>
                          "${mechanic.mechanicName}-${mechanic.mechanicNumber}")
                      .toList();

              if (mecNameList.isNotEmpty) {
                final orion = mecNameList.join(",");
                questions
                    .where((element) =>
                        element.question.trim().toLowerCase() ==
                        "Select Mechanics".toLowerCase())
                    .forEach((element) {
                  element.options = orion;
                });
              }
            } catch (e) {
              debugPrint('Failed to load mechanics: $e');
            }
          }

          // Inject recruiter options only when online (or if already available in memory).
          if (questions.any((element) =>
              element.question.trim().toLowerCase() ==
                  "Retailer/Workshop Name".toLowerCase() ||
              element.question.trim().toLowerCase() ==
                  "Retailer Name".toLowerCase() ||
              element.question.trim().toLowerCase() ==
                  "Select Retailer".toLowerCase())) {
            try {
              final isOnline = await _offlineService.isOnline();
              if (isOnline) {
                recs = await repo.getRecruiters(retailerName,selectedMechanicName,[
      'master data',
     ].contains(selectedCampaign?.name.trim().toLowerCase()));
              }
              if (recs.isNotEmpty) {
                final optionsList = recs.map((e) => e.counterName).toList();
                final onion = optionsList.join(",");
                questions
                    .where((element) =>
                        element.question.trim().toLowerCase() ==
                            "Retailer/Workshop Name".toLowerCase() ||
                        element.question.trim().toLowerCase() ==
                            "Retailer Name".toLowerCase())
                    .forEach((element) {
                  element.options = onion;
                });
              }
            } catch (e) {
              debugPrint('Failed to load recruiters: $e');
            }
          }

          questions.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
          section.selectedSectionQuestions = questions;
        }

        _updateQuestionModelWithRule();
        emit(CampaignQuestionsLoadedState());
      } catch (e, st) {
        debugPrint('GetQuestionsForSection error: $e');
        debugPrint('$st');
        emit(SnackbarMessageCampaignState(
            'Unable to load this section. Please try again.'));
        emit(CampaignQuestionsLoadedState());
      }
    });

    on((SaveCampaignAnswersEvent event, emit) async {
      isloading = true;
      emit(SavingAnswersLoadingState());
      saveAnswersForSelectedSection();
      final unAnsweredSection = selectedCampSections.firstWhereOrNull(
          (element) => element.selectedSectionQuestions.isEmpty);
      if (unAnsweredSection != null) {
        isloading = false;
        emit(SnackbarMessageCampaignState(
            "Please answer for Section: ${unAnsweredSection.name}"));
        return;
      }
      final notAnsweredQuestions = event.checkLeftAnswer
          ? _totalNotAnsweredQuestions()
          : <CampaignQuestionModel>[];

      if (notAnsweredQuestions.isNotEmpty) {
        isloading = false;
        emit(SnackbarMessageCampaignState(
            "Please answer for ${notAnsweredQuestions.first.question}"));
        return;
      }
      final notAnsweredIssuesQuestions = event.checkLeftAnswer
          ? _totalNotAnsweredIssuesQuestions()
          : <CampaignQuestionModel>[];

      if (notAnsweredIssuesQuestions.isNotEmpty) {
        isloading = false;
        emit(SnackbarMessageCampaignState("Kindly fill all mandatory field."));
        return;
      }

      final notAnsweredIssuesRemarkQuestions = event.checkLeftAnswer
          ? _totalNotAnsweredIssuesRemarkQuestions()
          : <CampaignQuestionModel>[];

      if (notAnsweredIssuesRemarkQuestions.isNotEmpty) {
        isloading = false;
        emit(SnackbarMessageCampaignState("Kindly fill all mandatory field."));
        return;
      }
      if (!_checkValidations(emit)) return;
      if (!checkOSSM(selectedCampSections)) {
        isloading = false;
        emit(SnackbarMessageCampaignState(
            "Please answer for required questions of all added Segment."));
        return;
      }

      final alreadyVisited = await repo.hasStoreBeenVisitedToday(storeId);
      if (alreadyVisited) {
        isloading = false;
        emit(SnackbarMessageCampaignState(
            "Store already visited today by another FOS. No further action allowed"));
        return;
      }
      try {
        final userLocation =
            await ContinuousLocationService.instance.resolveForSecureAction();
        if (from == AppPaths.store &&
            (AppStorage()
                    .userDetail
                    ?.configuration
                    .requiredGeoFencingForMarkIn ??
                false)) {
          final distance = distanceFromStore(userLocation, storeLat, storeLong);
          if (distance > AppConstant.storeRange) {
            isloading = false; // Fix Issue 1: Reset loading state before return
            emit(SnackbarMessageCampaignState(
                'You are not in location range. Away $distance m'));
            return;
          }
        }

        // Check online status BEFORE trying to upload images
        final isOnline = await _offlineService.isOnline();

        // If offline, don't upload images - keep local paths
        // bySync: false because this is user-initiated (not auto sync)
        final reqBody = await _getSubmitRequestBody(userLocation,
            shouldUploadImages: isOnline, bySync: false);

        if (!checkValidMechanicEnrolMentORActivation(
            reqBody, recruiterModelList)) {
          isloading = false; // Fix Issue 1: Reset loading state before return
          emit(SnackbarMessageCampaignState(
              'Maximum 2 retailers are allowed per mechanic.'));
          return;
        }

        // Try to save - will queue if offline
        try {
          final score = await repo.saveCampaignAnswers(reqBody);

          if (score.uuId.isNotEmpty) {
            // Online submission successful
            if (checkMaster(reqBody)) {
              await _addMasterData(reqBody);
            }
            if (checkMechanicEnrolMentORActivation(reqBody)) {
              await _addMechanicEnrolMentOrActivation(
                  reqBody, recruiterModelList);
            }
            if (checkRetailerVisit(reqBody)) {
              await _retailerVisit(reqBody);
            }
            if (checkISP(reqBody)) {
              await _addISPRecord(reqBody, score.uuId);
            }
            await _addSegment(reqBody, score.uuId);

            // Fix Issue 4: Reset state BEFORE emitting states
            isloading = false;
            canpopshow = true;
            indexCampaign = -1;
            // Clear campaign state to allow opening other campaigns
            final campaignUuid = selectedCampaign?.uuid ?? "";
            selectedCampaign = null;
            allCampSections.clear();
            selectedCampSections.clear();

            add(GetSavedCampaignResponseEvent(campaignUuid));
            emit(SnackbarMessageCampaignState("Saved Successfully"));
            emit(ScoreCalculatedCampaignState());
          }
        } on OfflineSubmissionException catch (e) {
          // Fix Issue 2: Update existing submission instead of queuing again
          // The repository already queued it, we just need to add additional data
          Map<String, dynamic>? masterData;
          Map<String, dynamic>? mechanicData;
          Map<String, dynamic>? retailerVisitData;
          List<dynamic>? segmentData;

          if (checkMaster(reqBody)) {
            masterData = await _prepareMasterData(reqBody);
          }
          if (checkMechanicEnrolMentORActivation(reqBody)) {
            mechanicData = await _prepareMechanicData(reqBody);
          }
          if (checkRetailerVisit(reqBody)) {
            retailerVisitData = await _prepareRetailerVisitData(reqBody);
          }
          if (checkOSSM(selectedCampSections)) {
            segmentData = await _prepareSegmentData(reqBody);
          }

          // Update existing submission instead of queuing again
          await _offlineService.updateSubmission(
            submissionId: e.submissionId,
            masterData: masterData,
            mechanicData: mechanicData,
            retailerVisitData: retailerVisitData,
            segmentData: segmentData,
          );

          // Fix Issue 4: Reset state
          selectedCampaign = null;
          allCampSections.clear();
          selectedCampSections.clear();
          // Also clear dynamic segments so they don't leak into the next visit
          segmentList.clear();

          final pendingCount = _offlineService.getPendingSubmissionCount();
          // Fix Issue 3: Remove duplicate message - listener handles OfflineSubmissionQueuedState
          emit(OfflineSubmissionQueuedState(e.submissionId, pendingCount));
          isloading = false;
          canpopshow = true;
          emit(ScoreCalculatedCampaignState());
        } catch (error) {
          isloading = false;
          canpopshow = true; // Fix Issue 4: Reset canpopshow
          emit(SnackbarMessageCampaignState(error.toString()));
        }
      } catch (error) {
        isloading = false; // Fix Issue 1: Ensure loading is reset
        canpopshow = true; // Fix Issue 4: Reset canpopshow
        emit(SnackbarMessageCampaignState(error.toString()));
      }
    });

    on<AddAnotherSoldSagmentEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];
      List<String> questionName = [
        "competition brand sold",
        'remark',
        'upload photo',
        "castrol pack sold",
        "shell pack sold",
        "gulf pack sold",
        "valvoline pack sold",
        "motul pack sold",
        "total pack sold",
        "veedol pack sold",
      ];
      int index = 0;
      final questionAnswers =
          _getQuestionsAccordingToGivenAnswers(_allQuestions())
              .map((e) => e.toViewQuestionModel())
              .toList();
      while (index < questionAnswers.length) {
        if (questionName
            .contains(questionAnswers[index].question.toLowerCase().trim())) {
          fillQuestion.add(QuestionModel(
              isIssue: questionAnswers[index].isIssue,
              issuesImage: questionAnswers[index].issuesImage,
              issuesRemark: questionAnswers[index].issuesRemark,
              uuid: questionAnswers[index].uuid,
              question: questionAnswers[index].question,
              questionType: questionAnswers[index].questionType,
              options: questionAnswers[index].options,
              isRequired: questionAnswers[index].isRequired,
              questionOrder: questionAnswers[index].questionOrder,
              isEditable: true,
              campQuestionModel: questionAnswers[index].campQuestionModel));
        }
        index++;
      }
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });

    on<AddGiftSagmentEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];
      List<String> questionName = [
        "gift type",
        "gift qty",
      ];
      int index = 0;
      while (index < event.questionAnswers.length) {
        if (questionName.contains(
            event.questionAnswers[index].question.toLowerCase().trim())) {
          fillQuestion.add(QuestionModel(
              isIssue: event.questionAnswers[index].isIssue,
              issuesImage: event.questionAnswers[index].issuesImage,
              issuesRemark: event.questionAnswers[index].issuesRemark,
              uuid: event.questionAnswers[index].uuid,
              question: event.questionAnswers[index].question,
              questionType: event.questionAnswers[index].questionType,
              options: event.questionAnswers[index].options,
              isRequired: event.questionAnswers[index].isRequired,
              questionOrder: event.questionAnswers[index].questionOrder,
              isEditable: true,
              campQuestionModel:
                  event.questionAnswers[index].campQuestionModel));
        }

        index++;
      }
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });

    on<AddStockEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];
      List<String> questionName = [
        "product category",
        "product sub category",
        "product name",
        "internal name",
        "mrp- master",
        "mrp at store",
        "Stock Quantity in ADDES".toLowerCase(),
        "Stock Quantity in Store".toLowerCase()
      ];
      int index = 0;
      while (index < event.questionAnswers.length) {
        if (questionName.any((keyword) => event.questionAnswers[index].question
            .toLowerCase()
            .contains(keyword.toLowerCase()))) {
          fillQuestion.add(QuestionModel(
              isIssue: event.questionAnswers[index].isIssue,
              issuesImage: event.questionAnswers[index].issuesImage,
              issuesRemark: event.questionAnswers[index].issuesRemark,
              uuid: event.questionAnswers[index].uuid,
              question: event.questionAnswers[index].question,
              questionType: event.questionAnswers[index].questionType,
              options: event.questionAnswers[index].options,
              isRequired: event.questionAnswers[index].isRequired,
              questionOrder: event.questionAnswers[index].questionOrder,
              isEditable: true,
              campQuestionModel:
                  event.questionAnswers[index].campQuestionModel));
        }
        index++;
      }
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });

    on<AddDemoAuditEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];

      answerFor(String questionName) => questionAnswers
          .firstWhereOrNull((element) =>
              element.question.toString().trim().isSameWord(questionName))
          ?.answer;

      String anser = answerFor("Is demo unit available?") ?? "No";

      List<String> questionName = anser.toLowerCase().trim() == "yes"
          ? [
              "port 1 status",
              "port 1 dsn",
              "port 1 internet",
              "port 1 product category",
              "port 1 product sub category",
              "port 1 product name",
              "Port 1 internal name",
              "am audit dsn",
              "port 1 audit remark"
            ]
          : [
              "port 1 status",
              "port 1 internet",
            ];

      int index = 0;
      while (index < event.questionAnswers.length) {
        if (questionName.any((keyword) => event.questionAnswers[index].question
            .toLowerCase()
            .contains(keyword.toLowerCase()))) {
          fillQuestion.add(QuestionModel(
              isIssue: event.questionAnswers[index].isIssue,
              issuesImage: event.questionAnswers[index].issuesImage,
              issuesRemark: event.questionAnswers[index].issuesRemark,
              uuid: event.questionAnswers[index].uuid,
              question: event.questionAnswers[index].question,
              questionType: event.questionAnswers[index].questionType,
              options: event.questionAnswers[index].options,
              isRequired: event.questionAnswers[index].isRequired,
              questionOrder: event.questionAnswers[index].questionOrder,
              isEditable: true,
              answer: null,
              campQuestionModel:
                  event.questionAnswers[index].campQuestionModel));
        }
        index++;
      }
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });

    on<AddQtySagmentEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];
      List<String> questionName = [
        "product sold under",
        "enter sales (qty)",
      ];
      int index = 0;
      while (index < event.questionAnswers.length) {
        if (questionName.any((keyword) => event.questionAnswers[index].question
            .toLowerCase()
            .contains(keyword.toLowerCase()))) {
          fillQuestion.add(QuestionModel(
              isIssue: event.questionAnswers[index].isIssue,
              issuesImage: event.questionAnswers[index].issuesImage,
              issuesRemark: event.questionAnswers[index].issuesRemark,
              uuid: event.questionAnswers[index].uuid,
              question: event.questionAnswers[index].question,
              questionType: event.questionAnswers[index].questionType,
              options: event.questionAnswers[index].options,
              isRequired: event.questionAnswers[index].isRequired,
              questionOrder: event.questionAnswers[index].questionOrder,
              isEditable: true,
              campQuestionModel:
                  event.questionAnswers[index].campQuestionModel));
        }
        index++;
      }
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });

    on<AddProductSagmentEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];
      List<String> questionName = [
        "product type",
        "product name",
        "number of pack sold",
        "volume (qty) sold",
        "pack size",
        "volume sold",
        "gift type",
        "gift qty",
      ];
      int index = 0;
      while (index < event.questionAnswers.length) {
        if (questionName.contains(
            event.questionAnswers[index].question.toLowerCase().trim())) {
          fillQuestion.add(QuestionModel(
              isIssue: event.questionAnswers[index].isIssue,
              issuesImage: event.questionAnswers[index].issuesImage,
              issuesRemark: event.questionAnswers[index].issuesRemark,
              uuid: event.questionAnswers[index].uuid,
              question: event.questionAnswers[index].question,
              questionType: event.questionAnswers[index].questionType,
              options: event.questionAnswers[index].options,
              isRequired: event.questionAnswers[index].isRequired,
              questionOrder: event.questionAnswers[index].questionOrder,
              isEditable: true,
              campQuestionModel:
                  event.questionAnswers[index].campQuestionModel));
        }

        index++;
      }
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });


    on<AddOrderSheetEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];
      List<String> questionName = [
        'select product name with model',
        'order qty.'
      ];

      int index = 0;
      while (index < event.questionAnswers.length) {
        final vm = event.questionAnswers[index];
        if (questionName.contains(vm.question.toLowerCase().trim())) {
          vm.campQuestionModel?.answer = null;
          fillQuestion.add(QuestionModel(
            isIssue: vm.isIssue,
            issuesImage: vm.issuesImage,
            issuesRemark: vm.issuesRemark,
            uuid: vm.uuid,
            question: vm.question,
            questionType: vm.questionType,
            options: vm.options,
            isRequired: vm.isRequired,
            questionOrder: vm.questionOrder,
            answer: null,
            isEditable: true,
            campQuestionModel: vm.campQuestionModel,
          ));
        }
        index++;
      }
      fillQuestion.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      int index2 = 0;
      while (index2 < segmentList.length) {
        int index21 = 0;
        while (index21 < segmentList[index2].questionAnswers.length) {
          _updateSagmentQuestionAccToAnser(
              AnswerUpdatedCampaignEvent(
                  segmentList[index2].questionAnswers[index21].question,
                  "order sheet",
                  index2,
                  -1),
              emit,
              index2 == segmentList.length);
          index21++;
        }
        index2++;
      }
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });

    on<AddFixtureAuditEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];
      List<String> questionName = [
        "is fixture available?",
        "what type of fixture is available at the store?",
        "what is the condition of the fixture?",
        "auf light working",
        "security system working",
        "What are Outside the store elements available in the store?"
            .toLowerCase(),
        "image of fixture",
      ];

      int index = 0;
      while (index < event.questionAnswers.length) {
        final vm = event.questionAnswers[index];
        if (questionName.contains(vm.question.toLowerCase().trim())) {
          vm.campQuestionModel?.answer = null;
          fillQuestion.add(QuestionModel(
            isIssue: vm.isIssue,
            issuesImage: vm.issuesImage,
            issuesRemark: vm.issuesRemark,
            uuid: vm.uuid,
            question: vm.question,
            questionType: vm.questionType,
            options: vm.options,
            isRequired: vm.isRequired,
            questionOrder: vm.questionOrder,
            answer: null,
            isEditable: true,
            campQuestionModel: vm.campQuestionModel,
          ));
        }
        index++;
      }
      fillQuestion.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      int index2 = 0;
      while (index2 < segmentList.length) {
        int index21 = 0;
        while (index21 < segmentList[index2].questionAnswers.length) {
          _updateSagmentQuestionAccToAnser(
              AnswerUpdatedCampaignEvent(
                  segmentList[index2].questionAnswers[index21].question,
                  "osmm",
                  index2,
                  -1),
              emit,
              index2 == segmentList.length);
          index21++;
        }
        index2++;
      }
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });

    on<AddSagmentEvent>((event, emit) {
      List<QuestionModel> fillQuestion = [];
      List<String> questionName = [
        "select osmm segment",
        "select mechanic segment",
        "mechanic segment?",
        "mechanic name?",
        "select mechanics",
        "mechanic mobile no.?",
        "mechanic contact no",
        "enrolled in unnati ?",
        "active in unnati ?",
        "remark (if any)",
        'register in mobil miles',
        'reason why not registered in miles?',
        'redemption in mobil miles',
        'reason why not redemption in miles?'
      ];

      int index = 0;
      while (index < event.questionAnswers.length) {
        final vm = event.questionAnswers[index];
        if (questionName.contains(vm.question.toLowerCase().trim())) {
          vm.campQuestionModel?.answer = null;
          fillQuestion.add(QuestionModel(
            isIssue: vm.isIssue,
            issuesImage: vm.issuesImage,
            issuesRemark: vm.issuesRemark,
            uuid: vm.uuid,
            question: vm.question,
            questionType: vm.questionType,
            options: vm.options,
            isRequired: vm.isRequired,
            questionOrder: vm.questionOrder,
            answer: null,
            isEditable: true,
            campQuestionModel: vm.campQuestionModel,
          ));
        }
        index++;
      }
      fillQuestion.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
      segmentList.add(
          SegmentModel(fillQuestion, "campaign_${selectedCampaign?.name}"));
      int index2 = 0;
      while (index2 < segmentList.length) {
        int index21 = 0;
        while (index21 < segmentList[index2].questionAnswers.length) {
          _updateSagmentQuestionAccToAnser(
              AnswerUpdatedCampaignEvent(
                  segmentList[index2].questionAnswers[index21].question,
                  "osmm",
                  index2,
                  -1),
              emit,
              index2 == segmentList.length);
          index21++;
        }
        index2++;
      }
      emit(SagmentAddSuccessfully());
      add(ChangeStateEvent());
    });
  }

  _updateSagmentQuestionAccToAnser(
      AnswerUpdatedCampaignEvent event, emit, emitEvent) {
        List<String> questionName = 
        
        event.sectionName.trim().toLowerCase() == 'order sheet'
        ?[
          "select product name with model",
          "order qty."
        ]  :  event.sectionName.trim().toLowerCase() == 'isp'
        ? [
            "competition brand sold",
            'remark',
            'upload photo',
            "shell pack sold",
            "castrol pack sold",
            "gulf pack sold",
            "valvoline pack sold",
            "motul pack sold",
            "total pack sold",
            "veedol pack sold",
          ]
        : event.sectionName.trim().toLowerCase() == 'fixture audit' ||   event.sectionName.trim().toLowerCase() == 'vm fixture audit'
            ? [
                "is fixture available?",
                "what type of fixture is available at the store?",
                "what is the condition of the fixture?",
                "auf light working",
                "security system working"
                        "What are Outside the store elements available in the store? (Multiple choice options: Flanges/ Lit Hanging board, Push & Pull sticker, A3 Poster, Vinyl branding)."
                    .toLowerCase(),
                "image of fixture"
              ]
            : [
                "select osmm segment",
                "select mechanic segment",
                "mechanic segment?",
                "mechanic name?",
                "select mechanics",
                "mechanic mobile no.?",
                "mechanic contact no",
                "enrolled in unnati ?",
                "active in unnati ?",
                "remark (if any)",
                'register in mobil miles',
                'reason why not registered in miles?',
                'redemption in mobil miles',
                'reason why not redemption in miles?'
              ];
    if (event.index >= 0 &&
        questionName.contains(event.question.toLowerCase())) {
      final allQuestion = _allQuestions();
      final evention = segmentList[event.index]
          .questionAnswers
          .firstWhereOrNull((q) =>
              q.question.toLowerCase().trim() ==
              event.question.toLowerCase().trim());
      final eventQuestion = allQuestion.firstWhereOrNull((q) =>
          q.question.toLowerCase().trim() ==
          event.question.toLowerCase().trim());
      if (evention != null && eventQuestion != null) {
        eventQuestion.answer = evention.answer;
      }

      bool ruleMatches(CampaignQuestionModel trigger, Rule rule) {
        final compareAnswer = (trigger.answer?.split(',') ?? <String>[])
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final ruleAnswers = rule.answer
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if ((trigger.inputTypeValidation) == "MULTI_SELECT_CHECKBOX" ||
            (trigger.inputTypeValidation) == "MULTI_SELECT_DROPDOWN") {
          return hasCommonIgnoreCase(compareAnswer, ruleAnswers);
        }

        return compareAnswer.contains(rule.answer) ||
            trigger.answer?.trim().toLowerCase() ==
                rule.answer.trim().toLowerCase();
      }

      // Sync (add/remove) all dependent questions for this changed answer.
      // Also remove descendants of any removed question (cascade).
      if (eventQuestion != null) {
        final segment = segmentList[event.index];

        // Build uuid->CampaignQuestionModel map and sync answers from the visible list.
        final byUuid = <String, CampaignQuestionModel>{};
        for (final q in allQuestion) {
          byUuid[q.uuid] = q;
        }
        for (final visible in segment.questionAnswers) {
          final model = byUuid[visible.uuid];
          if (model != null) {
            model.answer = visible.answer;
          }
        }

        bool isVisible(String uuid) =>
            segment.questionAnswers.any((q) => q.uuid == uuid);
        void removeVisible(String uuid) =>
            segment.questionAnswers.removeWhere((q) => q.uuid == uuid);
        void addVisible(CampaignQuestionModel q) {
          if (!isVisible(q.uuid)) {
            q.answer = null;
            segment.questionAnswers.add(q.toViewQuestionModel());
          }
        }

        final queue = <String>[eventQuestion.uuid];
        final visited = <String>{};

        while (queue.isNotEmpty) {
          final triggerUuid = queue.removeAt(0);
          if (!visited.add(triggerUuid)) continue;

          final trigger = byUuid[triggerUuid];
          if (trigger == null) continue;

          final dependentQuestions = allQuestion
              .where((q) => q.rules.any((r) => r.questionUuid == triggerUuid))
              .toList();

          for (final dependent in dependentQuestions) {
            final shouldShow = dependent.rules.any(
              (r) => r.questionUuid == triggerUuid && ruleMatches(trigger, r),
            );

            final exists = isVisible(dependent.uuid);

            if (shouldShow) {
              if (!exists) {
                addVisible(dependent);
                // Newly added question may unlock its own dependents.
                queue.add(dependent.uuid);
              }
            } else {
              if (exists) {
                // Remove this question and cascade to its descendants.
                removeVisible(dependent.uuid);
                // Clear cached answer too so downstream checks don't accidentally match.
                final m = byUuid[dependent.uuid];
                if (m != null) m.answer = null;
                queue.add(dependent.uuid);
              }
            }
          }
        }

        segment.questionAnswers
            .sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
      }
    }

    if (emitEvent) {
      add(ChangeStateEvent());
    }
  }

  double distanceFromStore(
      Position userLocation, double latitude, double longitude) {
    return Geolocator.distanceBetween(
        latitude, longitude, userLocation.latitude, userLocation.longitude);
  }

  bool checkOSSM(List<CampaignQuestionSectionModel> selectedCampSections) {
    bool verify = true;
    final isOsmm = selectedCampSections.any((section) =>
        ["osmm", "isp"].contains(section.name.toString().toLowerCase()));
    if (isOsmm) {
      for (SegmentModel element in segmentList) {
        if (element.questionAnswers.any((element) =>
            element.isRequired && (element.answer ?? "").trim().isEmpty)) {
          return false;
        }
      }
    }
    return verify;
  }

  bool checkValidMechanicEnrolMentORActivation(
      Map<String, Object> reqBody, List<RecruiterModel> recruiterModelList) {
    final questList = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .first['questions'] as List<Map<String, dynamic>>;

    answerFor(String questionName) => questList.firstWhereOrNull((element) =>
        element['questionName']?.toString().trim().isSameWord(questionName) ??
        false)?['answer'];

    if ((reqBody['campaignResponse'] as List<Map<String, Object>>).any(
        (element) =>
            element["sectionName"].toString().toLowerCase() ==
                "Mechanic registration".toLowerCase() ||
            element["sectionName"].toString().toLowerCase() ==
                "Mechanic Activation".toLowerCase() ||
            element["sectionName"].toString().toLowerCase() ==
                "Mechanic Enrollment".toLowerCase())) {
      String anser = answerFor("Is Mechanic buying from Multiple Outlet?");
      if (anser.toLowerCase().trim() == "yes" &&
          recruiterModelList.length > 2) {
        return false;
      }
    }

    return true;
  }

  bool checkMechanicEnrolMentORActivation(Map<String, Object> reqBody) {
    return (reqBody['campaignResponse'] as List<Map<String, Object>>).any(
        (element) =>
            element["sectionName"].toString().toLowerCase() ==
                "Mechanic registration".toLowerCase() ||
            element["sectionName"].toString().toLowerCase() ==
                "Mechanic Activation".toLowerCase() ||
            element["sectionName"].toString().toLowerCase() ==
                "Mechanic Enrollment".toLowerCase());
  }

  bool checkRetailerVisit(Map<String, Object> reqBody) {
    return (reqBody['campaignResponse'] as List<Map<String, Object>>).any(
        (element) =>
            element["sectionName"].toString().toLowerCase() ==
            "NBA and Reactivation Account".toLowerCase());
  }

  bool checkMaster(Map<String, Object> reqBody) {
    return (reqBody['campaignResponse'] as List<Map<String, Object>>).any(
        (element) =>
            element["sectionName"].toString().toLowerCase() ==
            "New Retailer and Mechanic registration".toLowerCase());
  }

  bool checkISP(Map<String, Object> reqBody) {
    return (reqBody['campaignResponse'] as List<Map<String, Object>>).any(
        (element) =>
            element["sectionName"].toString().toLowerCase() ==
            "ISP".toLowerCase());
  }

  Future<void> _addSegment(Map<String, Object> reqBody, String uuId) async {
    final isOsmm = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .any((element) => ["osmm", "isp", "record sales"]
            .contains(element["sectionName"].toString().toLowerCase()));

    if (isOsmm) {
      Map<String, dynamic> section =
          (reqBody['campaignResponse'] as List<Map<String, Object>>).firstWhere(
              (element) => ["osmm", "isp", 'record sales']
                  .contains(element["sectionName"].toString().toLowerCase()));
      final campaignUuid = reqBody['campaignUuid'];

      List<dynamic> request = [];
      int groupIndex = 0;
      for (SegmentModel element in segmentList) {
        int index = 0;
        List<CampaignQuestionModel> questionList = [];
        while (index < element.questionAnswers.length) {
          questionList.add(element.questionAnswers[index].campQuestionModel!);
          questionList[index].answer = element.questionAnswers[index].answer;
          index++;
        }
        request.add(SagmentRequest(
          groupname: "$groupIndex",
          sectionUuid: section["sectionUuid"],
          campaignUuid: campaignUuid.toString(),
          group: questionList,
        ).toJson());
        groupIndex++;
      }
      bool add = await repo.addSagment(
          request, campaignUuid.toString(), storeId, uuId);
      if (add) {
        segmentList.clear();
      }
    }
  }

  Future<void> _addMechanicEnrolMentOrActivation(Map<String, Object> reqBody,
      List<RecruiterModel> recruiterModelList) async {
    final questList = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .first['questions'] as List<Map<String, dynamic>>;

    answerFor(String questionName) => questList.firstWhereOrNull((element) =>
        element['questionName']?.toString().trim().isSameWord(questionName) ??
        false)?['answer'];

    String answer = answerFor("Select Mechanics") ?? "";

    String id = (mechanics
                .firstWhereOrNull((mechanic) =>
                    answer ==
                    "${mechanic.mechanicName}-${mechanic.mechanicNumber}")
                ?.id ??
            "")
        .toString();

    var bodyMap = <String, dynamic>{};
    //
    if ((reqBody['campaignResponse'] as List<Map<String, Object>>).any(
        (element) =>
            element["sectionName"].toString().toLowerCase() ==
            "Mechanic Activation".toLowerCase())) {
      String anser = answerFor("Is Mechanic buying from Multiple Outlet?");
      bodyMap = {"isActivated": true};
      if (anser.toLowerCase().trim() == "yes") {
        bodyMap = {
          "isActivated": true,
          "retailerIds":
              recruiterModelList.map((retailer) => retailer.id).toList(),
        };
      }
    } else if ((reqBody['campaignResponse'] as List<Map<String, Object>>).any(
        (element) =>
            element["sectionName"].toString().toLowerCase() ==
            "Mechanic Enrollment".toLowerCase())) {
      String anser = answerFor("Is Mechanic buying from Multiple Outlet?");
      bodyMap = {"isEnrolled": true};
      if (anser.toLowerCase().trim() == "yes") {
        bodyMap = {
          "isEnrolled": true,
          "retailerIds":
              recruiterModelList.map((retailer) => retailer.id).toList(),
        };
      }
    }
    if (bodyMap.isNotEmpty) {
      await repo.saveActivationOrEnrolment(bodyMap, id);
    }
  }

  Future<void> _addISPRecord(Map<String, Object> reqBody, String uuId) async {
    final questList = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .first['questions'] as List<Map<String, dynamic>>;

    answerFor(String questionName) => questList.firstWhereOrNull((element) =>
        element['questionName']?.toString().trim().isSameWord(questionName) ??
        false)?['answer'];

    final bodyMap = <String, String>{
      "userId": (AppStorage().userDetail?.id ?? 1).toString(),
      "campaignResponseUuid": uuId,
      "gcin": answerFor('GCIN Code') ?? '',
      "totalPacksSold": answerFor('Number of pack Sold') ??
          answerFor('Total Pack Sold') ??
          '',
      "products": answerFor('Product Name') ?? '',
      "productType": answerFor('Product Type') ?? '',
      "productName": answerFor('Product Name') ?? '',
      "volumeSold": answerFor("Pack Size") ?? answerFor('Volume Sold') ?? '',
      "numberOfPackSold": answerFor('Number of pack Sold') ?? '',
    };

    await repo.saveISPVisit(bodyMap);
  }

  Future<void> _retailerVisit(Map<String, Object> reqBody) async {
    final questList = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .first['questions'] as List<Map<String, dynamic>>;

    answerFor(String questionName) => questList.firstWhereOrNull((element) =>
        element['questionName']?.toString().trim().isSameWord(questionName) ??
        false)?['answer'];

    final bodyMap = <String, String>{
      "type": (answerFor("Type of account ") ?? "")
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll(RegExp('\\s+'), ''), //"leadgeneration",
      "retailerName": answerFor("Retailer/Workshop Name") ??
          answerFor("Retailer Name ") ??
          "",
      "retailerContactNo": answerFor("Contact Number ") ?? "",
      "outletName":
          answerFor("Workshop Name ") ?? answerFor("Outlet Name ") ?? "",
      "detailAddress": answerFor("Address") ?? "",
      "outletImage":
          answerFor("Workshop Image ") ?? answerFor("Outlet Image ") ?? "",
      "outletSegment": answerFor("Select Segment ") ?? "",
      "isOrderConfirmed": answerFor("Is an order confirmed ?") ?? "",
      "userId": (AppStorage().userDetail?.id ?? 1).toString()
    };
    await repo.saveRetailerVisit(bodyMap);
  }

  Future<void> _addMasterData(Map<String, Object> reqBody) async {
    final questList = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .first['questions'] as List<Map<String, dynamic>>;

    answerFor(String questionName) => questList.firstWhereOrNull((element) =>
        element['questionName']?.toString().trim().isSameWord(questionName) ??
        false)?['answer'];

    if ((answerFor("Type") ?? "")
        .toString()
        .trim()
        .toLowerCase()
        .contains('Retailer'.toLowerCase())) {
      final bodyMap = <String, String>{
        "retailerName": answerFor("Retailer/Workshop Name") ??
            answerFor("Retailer Name") ??
            "",
        "counterName":
            answerFor("Workshop Name") ?? answerFor("Outlet Name") ?? "",
        "counterPerson": answerFor("Contact Person Name") ?? "",
        "contactNumber": answerFor('Contact Number') ?? '',
        "address":
            answerFor('Workshop Address') ?? answerFor('Outlet Address') ?? '',
        "pin": answerFor('Pincode') ?? '',
        "gcinCode": answerFor('GCIN Code') ?? '',
        "district": answerFor('District') ?? '',
        "state": answerFor('State') ?? '',
        "image": answerFor('Counter Image') ?? '',
        "outletSegment":
            answerFor('Workshop Segment') ?? answerFor('Outlet Segment') ?? '',
        "mappedTo": (AppStorage().userDetail?.id ?? 1).toString(),
      };
      await repo.saveRecruiter(bodyMap);
    } else if ((answerFor("Type") ?? "")
        .trim()
        .toLowerCase()
        .contains('Mechanic'.toLowerCase())) {
      final bodyMap = <String, dynamic>{
        "mechanicName": answerFor('Mechanic Name') ?? "",
        "mechanicNumber": answerFor('Mechanic Contact No') ?? "",
        "outletName":
            answerFor("Workshop Name") ?? answerFor('Outlet Name') ?? '',
        "address":
            answerFor('Workshop Address') ?? answerFor('Outlet Address') ?? '',
        "pin": answerFor('Pincode') ?? '',
        "district": answerFor('District') ?? '',
        "state": answerFor('State') ?? '',
        "image": answerFor('Mechanic image') ?? answerFor('upload image') ?? "",
        "outletImage": answerFor('Workshop image') ??
            answerFor('Outlet image') ??
            answerFor('upload image') ??
            "",
        "outletSegment":
            answerFor('Workshop Segment') ?? answerFor('Outlet Segment') ?? '',
        "mappedTo": (AppStorage().userDetail?.id ?? 1).toString(),
        "retailerIds":
            recruiterModelList.map((retailer) => retailer.id).toList()
      };
      await repo.saveMechanic(bodyMap);
    }
  }

  Future<Map<String, Object>> _getSubmitRequestBody(Position userLocation,
      {bool shouldUploadImages = true, bool bySync = false}) async {
    final campaignResponse = selectedCampSections.map((section) async {
      final questions = section.selectedSectionQuestions
          .where((question) => question.answer?.trim().isNotEmpty ?? false)
          .map((question) async {
        var answer = question.answer;

        // Only upload images if online and shouldUploadImages is true
        if (question.questionInputType == QuestionInputType.image &&
            shouldUploadImages) {
          if (!question.answer!.urlValid()) {
            try {
              answer = await repo.getImageUrlPath(question.answer ?? '');
            } catch (e) {
              // If upload fails, keep original path (will be uploaded during sync)
              answer = question.answer;
            }
          }
        }

        // Handle issuesImage - convert local paths to URLs only if online
        var issuesImage = question.issuesImage;
        if (issuesImage != null &&
            issuesImage.isNotEmpty &&
            shouldUploadImages) {
          final imagePaths = issuesImage.split(",");
          final List<String> uploadedImageUrls = [];

          for (final imagePath in imagePaths) {
            final trimmedPath = imagePath.trim();
            if (trimmedPath.isNotEmpty) {
              if (trimmedPath.urlValid()) {
                // Already a URL, keep it
                uploadedImageUrls.add(trimmedPath);
              } else {
                // Local file path, upload it only if online
                try {
                  final url = await repo.getImageUrlPath(trimmedPath);
                  uploadedImageUrls.add(url);
                } catch (e) {
                  // If upload fails, keep the original path (will be uploaded during sync)
                  uploadedImageUrls.add(trimmedPath);
                }
              }
            }
          }

          issuesImage = uploadedImageUrls.join(",");
        }
        // If shouldUploadImages is false (offline), keep issuesImage as-is (local paths)

        return {
          "questionName": question.question,
          "questionUuid": question.uuid,
          "questionDataType": question.questionInputType.toCampaignStringName(),
          "answer": answer,
          "issue": question.isIssue,
          "issuesImage": issuesImage,
          "issuesRemarks": question.issuesRemark,
          "correctAnswer": question.correctAnswer,
          'mandatory': question.isInputMandatory
        };
      });
      return {
        "sectionName": section.name,
        "sectionUuid": section.uuid,
        "questions": await Future.wait(questions),
      };
    });

    return {
      "storeId": storeId,
      "campaignName": selectedCampaign?.name ?? "",
      "campaignUuid": selectedCampaign?.uuid ?? "",
      "campaignResponse": await Future.wait(campaignResponse),
      "latitude": userLocation.latitude,
      "longitude": userLocation.longitude,
      "bySync": bySync, // Add bySync flag
    };
  }

  bool _checkValidations(Emitter<CampaignState> emit) {
    for (final q in _allQuestions()) {
      if (q.answer?.trim().isEmpty ?? true) {
        continue;
      } else if (q.inputTypeValidation == 'pan_number') {
        final bool mobileValid =
            RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(q.answer ?? '');
        if ((q.answer ?? '').isEmpty) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter PAN number for ${q.question}"));
        } else if (!mobileValid) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter valid PAN for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'aadhar_number') {
        final bool aadharValid = RegExp(r'^[2-9]{1}[0-9]{11}$')
            // RegExp(r"^[2-9]{1}[0-9]{3}\\s[0-9]{4}\\s[0-9]{4}$")
            .hasMatch(q.answer ?? '');
        if ((q.answer ?? '').isEmpty) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter Aadhar number for ${q.question}"));
        } else if (!aadharValid) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter valid Aadhar for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'mobile_number') {
        final bool mobileValid =
            RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(q.answer ?? '');
        if ((q.answer ?? '').isEmpty) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter mobile number for ${q.question}"));
        } else if (!mobileValid) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter valid contact for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'gst_number') {
        final bool gstValid = RegExp(
                r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$')
            .hasMatch((q.answer ?? '').trim().toUpperCase());
        if (!gstValid) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter valid GST number for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'fssai_number') {
        final bool fssaiValid = RegExp(r'^[1-3][0-9]{13}$')
            .hasMatch((q.answer ?? '').trim());
        if (!fssaiValid) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter valid FSSAI number for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'udyam_number') {
        final bool udyamValid = RegExp(r'^UDYAM-[A-Z]{2}-\d{2}-\d{7}$')
            .hasMatch((q.answer ?? '').trim().toUpperCase());
        if (!udyamValid) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter valid UDYAM number for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'email') {
        final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(q.answer ?? '');
        if (!emailValid) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter valid email for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'url') {
        const regex =
            r"^(?:http|https):\/\/[\w\-_]+(?:\.[\w\-_]+)+[\w\-.,@?^=%&:/~\\+#]*$";
        final bool validURl = RegExp(regex).hasMatch(q.answer ?? '');
        if (!validURl) {
          isloading = false;
          emit(SnackbarMessageCampaignState(
              "Please enter valid URL for ${q.question}"));
          return false;
        }
      }
    }
    return true;
  }

  void saveAnswersForSelectedSection() {
    var lastSelectedQuestions = allCampSections
        .firstWhereOrNull((element) => element.uuid == lastSelectedSectionUuid)
        ?.selectedSectionQuestions;
    for (final q in questionAnswers) {
      lastSelectedQuestions
          ?.firstWhereOrNull((element) => element.uuid == q.uuid)
          ?.answer = q.answer;
      lastSelectedQuestions
          ?.firstWhereOrNull((element) => element.uuid == q.uuid)
          ?.isEditable = q.isEditable;
      lastSelectedQuestions
          ?.firstWhereOrNull((element) => element.uuid == q.uuid)
          ?.isIssue = q.isIssue;
      lastSelectedQuestions
          ?.firstWhereOrNull((element) => element.uuid == q.uuid)
          ?.issuesImage = q.issuesImage;
      lastSelectedQuestions
          ?.firstWhereOrNull((element) => element.uuid == q.uuid)
          ?.issuesRemark = q.issuesRemark;
    }
  }

  List<CampaignQuestionModel> _allQuestions() {
    return allCampSections
        .map((e) => e.selectedSectionQuestions)
        .expand((element) => element)
        .toList();
  }

  List<CampaignQuestionModel> _totalNotAnsweredQuestions() {
    return _getQuestionsAccordingToGivenAnswers(
            _findValidCampaignQuestion(_allQuestions()))
        .where((element) =>
            element.isInputMandatory &&
            (element.answer?.trim().isEmpty ?? true))
        .toList();
  }

  List<CampaignQuestionModel> _totalNotAnsweredIssuesQuestions() {
    return _getQuestionsAccordingToGivenAnswers(
            _findValidCampaignQuestion(_allQuestions()))
        .where((element) =>
            element.isIssue &&
            (element.answer?.split(',') ?? [])
                .map((element) => element.trim())
                .contains(element.correctAnswer?.trim()) &&
            //  (element.issuesImage?.trim().isEmpty ?? true) &&
            (element.issuesRemark?.trim().isEmpty ?? true))
        .toList();
  }

  List<CampaignQuestionModel> _totalNotAnsweredIssuesRemarkQuestions() {
    return _getQuestionsAccordingToGivenAnswers(
            _findValidCampaignQuestion(_allQuestions()))
        .where((element) =>
                element.isIssue &&
                (element.answer?.split(',') ?? [])
                    .map((element) => element.trim())
                    .contains(element.correctAnswer?.trim()) &&
                (element.issuesImage?.trim().isEmpty ?? true)
            //  (element.issuesRemark?.trim().isEmpty ?? true)
            )
        .toList();
  }

  void _answerUpdatedEvent(AnswerUpdatedCampaignEvent event, emit) async {
    // Persist latest answers for the previously selected section
    saveAnswersForSelectedSection();
    _updateQuestionModelWithRule();
    // Apply dependent data updates (recruiter, mechanic, ISP products)
    await _tempRecruiterConditionsSet(event, emit);
    await _tempMechanicConditionsSet(event, emit);
    if ([
      'isp',
      'osmm',
      'mechanic activation',
      'mechanic visit',
      'stock',
      "demo audit",
       'vm demo audit',
      'fixture audit',
       'vm fixture audit',
       'order sheet'
    ].contains(event.sectionName.trim().toLowerCase())) {
      await _tempISPProductConditionsSet(event, emit);
      _updateSagmentQuestionAccToAnser(event, emit, true);
    }
    if (['isp', 'mechanic visit', 'stock', "demo audit", 'vm demo audit',]
            .contains(event.sectionName.trim().toLowerCase()) &&
        ['port 1 product name', "product name"]
            .contains(event.question.trim().toLowerCase())) {
      _tempSetPackSizeAnswer(event);
    }

    // Clear OSMM/record-sales segments when category changes
    if ("record sales" == event.sectionName.trim().toLowerCase() &&
        event.question.trim().toLowerCase() ==
            "Category – Sold".trim().toLowerCase()) {
      segmentList.clear();
    }
    saveAnswersForSelectedSection();
    // Recalculate visible questions once and emit a single state
    _updateQuestionModelWithRule();
    _updateVisibleSections();
    emit(CampaignQuestionsLoadedState());
  }

  Future<void> _uploadImageEvent(UploadImageEvent event, emit) async {
    try {
      final isOnline = await _offlineService.isOnline();

      if (isOnline) {
        // Online: Upload immediately and get URL
        final image = await repo.getImageUrlPath(event.path);
        if (event.isIssue) {
          final question = questionAnswers.firstWhereOrNull(
              (element) => element.uuid == event.questionUuid);

          final allimage = question?.issuesImage?.split(",") ?? [];

          if (allimage.isEmpty) {
            question?.issuesImage = image;
          } else {
            if (allimage.length <= event.index) {
              allimage.add("");
            }
            allimage[event.index] = image;
            question?.issuesImage = allimage.join(",");
          }
        } else {
          if (event.sagmentIndex >= 0) {
            segmentList[event.sagmentIndex]
                .questionAnswers
                .firstWhereOrNull(
                    (element) => element.uuid == event.questionUuid)
                ?.answer = image;
          } else {
            questionAnswers
                .firstWhereOrNull(
                    (element) => element.uuid == event.questionUuid)
                ?.answer = image;
          }
        }
      } else {
        // Offline: Store local file path, will be uploaded during sync
        if (event.isIssue) {
          final question = questionAnswers.firstWhereOrNull(
              (element) => element.uuid == event.questionUuid);

          final allimage = question?.issuesImage?.split(",") ?? [];

          if (allimage.isEmpty) {
            question?.issuesImage = event.path;
          } else {
            if (allimage.length <= event.index) {
              allimage.add("");
            }
            allimage[event.index] = event.path;
            question?.issuesImage = allimage.join(",");
          }
        } else {
          questionAnswers
              .firstWhereOrNull((element) => element.uuid == event.questionUuid)
              ?.answer = event.path;
        }
      }

      // _updateQuestionModelWithRule();
      emit(CampaignQuestionsLoadedState());
    } catch (error) {
      emit(SnackbarMessageCampaignState(
          "Failed to upload image: ${error.toString()}"));
    }
  }

  Future<void> _tempISPProductConditionsSet(
      AnswerUpdatedCampaignEvent event, emit) async {
    final ques = event.question.trim().toLowerCase();
    if (['product type', 'product sub category', "port 1 product sub category"]
        .contains(ques)) {
      await _setProductAnswers(true, event.index, emit);
    }
  }

  Future<void> _tempMechanicConditionsSet(
      AnswerUpdatedCampaignEvent event, emit) async {
    final ques = event.question.trim().toLowerCase();
    if (ques.contains('select mechanics')) {
      _setMechanicAnswers(true, event);
    }
  }

  Future<void> _tempRecruiterConditionsSet(
      AnswerUpdatedCampaignEvent event, emit) async {
    final ques = event.question.trim().toLowerCase();
    final typeQuestions = [
      "Retailer/Workshop Name".toLowerCase(),
      "type of counter",
      "type of lead",
      "retailer name",
      "type"
    ];
    final subQuestionCases = [
      "Retailer/Workshop Name".toLowerCase(),
      'select retailer',
      'select revisit retailer',
      "retailer name",
      "which retailer are you buying from?",
      "add outlet name"
    ];

    if (subQuestionCases.contains(ques)) {
      _setRecruiterAnswers(true, event.orderIndex);
    } else if (ques == 'type of account') {
      _setRecruiterAnswers(false, event.orderIndex);
      questionAnswers
          .firstWhereOrNull((element) =>
              typeQuestions.contains(element.question.trim().toLowerCase()))
          ?.answer = null;
      questionAnswers
          .firstWhereOrNull((element) =>
              subQuestionCases.contains(element.question.trim().toLowerCase()))
          ?.answer = null;
    } else if (typeQuestions.contains(ques)) {
      final answerForType = questionAnswers
              .firstWhereOrNull((element) => element.question.isSameWord(ques))
              ?.answer
              ?.trim()
              .toLowerCase() ??
          "";
      final existingRecCase = answerForType.contains('existing');
      final revisitCase = answerForType.contains('revisit');
      final buyfrom = answerForType.contains("mechanic");
      if (existingRecCase || revisitCase || buyfrom) {
        emit(CampaignListLoadingState());
        try {
          recs = await repo.getRecruiters(retailerName,selectedMechanicName,[
      'master data',
     ].contains(selectedCampaign?.name.trim().toLowerCase()));
          // .where((element) =>
          //     element.isNew == (revisitCase || existingRecCase))
          // .toList();
        } catch (e) {
          e.toString();
        }

        var retailersQ = questionAnswers.firstWhereOrNull((element) =>
            subQuestionCases.contains(element.question.trim().toLowerCase()));
        final optionsList = recs.map((e) => e.counterName).toList();
        retailersQ?.options = optionsList;
        retailersQ?.answer =
            null; // optionsList.isEmpty ? null : optionsList.first;

        // update Options globally
        allCampSections
            .firstWhereOrNull(
                (element) => element.uuid == lastSelectedSectionUuid)
            ?.selectedSectionQuestions
            .firstWhereOrNull((element) =>
                retailersQ?.question.isSameWord(element.question) ?? false)
            ?.options = optionsList.join(",");
      }
      _setRecruiterAnswers(existingRecCase || revisitCase, event.orderIndex);
    }
  }

  Future<void> _setProductAnswers(
      bool existingMechanicCase, int index, emit) async {
    if (index >= 0) {
      String selectedOption = segmentList[index]
              .questionAnswers
              .firstWhereOrNull((element) =>
                  element.question
                      .trim()
                      .toLowerCase()
                      .contains('product type') ||
                  element.question
                      .trim()
                      .toLowerCase()
                      .contains('port 1 product name') ||
                  element.question
                      .trim()
                      .toLowerCase()
                      .contains('product sub category') ||
                  element.question
                      .trim()
                      .toLowerCase()
                      .contains('port 1 product sub category'))
              ?.answer ??
          "";

      List<String> productList = [];
      String from = selectedCampaign?.name.toLowerCase() == 'isp'
          ? "isp"
          : ['stock audit', "demo audit","vm demo audit"]
                  .contains(selectedCampaign?.name.toLowerCase())
              ? ""
              : "mechanic";
      try {
        productInfo =
            await repo.getProductList(selectedOption, from);
        productList = productInfo
            .map((e) => (e.productSeries).trim())
            .where((e) => e.isNotEmpty)
            .toList();

        productList = productInfo
            .map((e) => (e.productSeries).trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } on Exception catch (e) {
        e.toString();
      }
      // String onion = productList.join(",");
      segmentList[index]
          .questionAnswers
          .where((element) =>
              element.question.trim().toLowerCase() ==
                  "product name".toLowerCase() ||
              element.question
                  .trim()
                  .toLowerCase()
                  .contains("port 1 product name"))
          .forEach((element) {
        element.answer = null;
        element.options = productList;
      });

      segmentList[index]
          .questionAnswers
          .where((element) =>
              element.question.trim().toLowerCase() ==
              "pack size".toLowerCase())
          .forEach((element) {
        element.answer = null;
        element.options = [];
      });
      saveAnswersForSelectedSection();
      _updateQuestionModelWithRule();

      // .firstWhereOrNull(
      //     (element) => element.question.isSameWord(question))
      // ?.answer = value;

      return;
    }

    String selectedOption = questionAnswers
            .firstWhereOrNull((element) =>
                element.question
                    .trim()
                    .toLowerCase()
                    .contains('product type') ||
                element.question
                    .trim()
                    .toLowerCase()
                    .contains('port 1 product name') ||
                element.question
                    .trim()
                    .toLowerCase()
                    .contains('product sub category') ||
                element.question
                    .trim()
                    .toLowerCase()
                    .contains('port 1 product sub category'))
            ?.answer ??
        "";
    var questions = selectedCampSections
        .firstWhere((element) => element.uuid == lastSelectedSectionUuid)
        .selectedSectionQuestions;

    List<String> productList = [];

    questions
        .where((element) =>
            element.question.trim().toLowerCase() ==
                "product name".toLowerCase() ||
            element.question
                .trim()
                .toLowerCase()
                .contains("port 1 product name"))
        .forEach((element) {
      element.answer = null;
      element.options = productList.join(",");
    });
    questions
        .where((element) =>
            element.question.trim().toLowerCase() == "pack size".toLowerCase())
        .forEach((element) {
      element.answer = null;
      element.options = "";
    });
    String from = selectedCampaign?.name.toLowerCase() == 'isp'
        ? "isp"
        : ['stock audit', "demo audit", 'vm demo audit',]
                .contains(selectedCampaign?.name.toLowerCase())
            ? ""
            : "mechanic";
    try {
      productInfo =
          await repo.getProductList(selectedOption, from);
      productList = productInfo
          .map((e) => (e.productSeries).trim())
          .where((e) => e.isNotEmpty)
          .toList();

      productList = productInfo
          .map((e) => (e.productSeries).trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } on Exception catch (e) {
      e.toString();
    }
    String onion = productList.join(",");

    questions
        .where((element) =>
            element.question.trim().toLowerCase() ==
                "product name".toLowerCase() ||
            element.question
                .trim()
                .toLowerCase()
                .contains("port 1 product name"))
        .forEach((element) {
      element.answer = null;
      element.options = onion;
    });
    saveAnswersForSelectedSection();
    _updateQuestionModelWithRule();
  }

  Future<void> _tempSetPackSizeAnswer(AnswerUpdatedCampaignEvent event) async {
    if (event.index >= 0) {
      String selectedOption = segmentList[event.index]
              .questionAnswers
              .firstWhereOrNull((element) =>
                  element.question
                      .trim()
                      .toLowerCase()
                      .contains("product name") ||
                  element.question
                      .trim()
                      .toLowerCase()
                      .contains("port 1 product name"))
              ?.answer ??
          "";
      final productInfoObject = productInfo.firstWhereOrNull((element) =>
          element.productSeries
              .trim()
              .toLowerCase()
              .contains(selectedOption.trim().toLowerCase()));

      segmentList[event.index]
          .questionAnswers
          .where((element) =>
              element.question.trim().toLowerCase() ==
              "pack size".toLowerCase())
          .forEach((element) {
        element.answer = null;
        element.options = productInfoObject?.packSizes ?? [];
      });

      Map<String, String?> subQuestions = {
        "mrp- master": productInfoObject?.packSizes?.first ?? "",
        "internal name": productInfoObject?.internalName,
        "port 1 internal name": productInfoObject?.internalName,
      };

      subQuestions.forEach((question, value) {
        segmentList[event.index]
            .questionAnswers
            .firstWhereOrNull(
                (element) => element.question.isSameWord(question))
            ?.answer = value;

        if (segmentList[event.index]
                .questionAnswers
                .firstWhereOrNull(
                    (element) => element.question.isSameWord(question))
                ?.answer
                ?.trim()
                .isNotEmpty ??
            false) {
          segmentList[event.index]
              .questionAnswers
              .firstWhereOrNull(
                  (element) => element.question.isSameWord(question))
              ?.isEditable = false;
        } else {
          segmentList[event.index]
              .questionAnswers
              .firstWhereOrNull(
                  (element) => element.question.isSameWord(question))
              ?.isEditable = true;
        }
      });
      saveAnswersForSelectedSection();
      _updateQuestionModelWithRule();
      return;
    }

    String selectedOption = questionAnswers
            .firstWhereOrNull((element) =>
                element.question
                    .trim()
                    .toLowerCase()
                    .contains("product name") ||
                element.question
                    .trim()
                    .toLowerCase()
                    .contains("port 1 product name"))
            ?.answer ??
        "";

    final productInfoObject = productInfo.firstWhereOrNull((element) => element
        .productSeries
        .trim()
        .toLowerCase()
        .contains(selectedOption.trim().toLowerCase()));

    var questions = selectedCampSections
        .firstWhere((element) => element.uuid == lastSelectedSectionUuid)
        .selectedSectionQuestions;

    questions
        .where((element) =>
            element.question.trim().toLowerCase() ==
            "Pack Size".trim().toLowerCase())
        .forEach((element) {
      element.answer = null;
      element.options = (productInfoObject?.packSizes ?? []).join(",");
    });

    Map<String, String?> subQuestions = {
      "mrp- master": productInfoObject?.packSizes?.first ?? "",
      "internal name": productInfoObject?.internalName,
      "port 1 internal name": productInfoObject?.internalName,
    };

    subQuestions.forEach((question, value) {
      questionAnswers
          .firstWhereOrNull((element) => element.question.isSameWord(question))
          ?.answer = value;

      if (questionAnswers
              .firstWhereOrNull(
                  (element) => element.question.isSameWord(question))
              ?.answer
              ?.trim()
              .isNotEmpty ??
          false) {
        questionAnswers
            .firstWhereOrNull(
                (element) => element.question.isSameWord(question))
            ?.isEditable = false;
      } else {
        questionAnswers
            .firstWhereOrNull(
                (element) => element.question.isSameWord(question))
            ?.isEditable = true;
      }
    });

    saveAnswersForSelectedSection();
    _updateQuestionModelWithRule();
  }

  Future<void> _setMechanicAnswers(
      bool existingMechanicCase, AnswerUpdatedCampaignEvent event) async {
    MechanicModel? mechanicModel;

    if (existingMechanicCase) {
      String selectedOption = event.index >= 0
          ? segmentList[event.index]
                  .questionAnswers
                  .firstWhereOrNull((element) =>
                      element.question
                          .trim()
                          .toLowerCase()
                          .contains('select mechanics') &&
                      element.questionOrder == event.orderIndex)
                  ?.answer ??
              ""
          : questionAnswers
                  .firstWhereOrNull((element) =>
                      element.question
                          .trim()
                          .toLowerCase()
                          .contains('select mechanics') &&
                      element.questionOrder == event.orderIndex)
                  ?.answer ??
              "";
      mechanicModel = mechanics.firstWhereOrNull((element) =>
          "${element.mechanicName}-${element.mechanicNumber}"
              .isSameWord(selectedOption));
    }

    Map<String, String?> mechanicSubQuestions =
        (selectedCampaign?.name.trim().toLowerCase() == "isp" &&
                event.orderIndex >= 4)
            ? {
                'Name': mechanicModel?.mechanicName ?? "",
                "Contact No.": mechanicModel?.mechanicNumber ?? "",
              }
            : {
                'Mechanic Name': mechanicModel?.mechanicName ?? "",
                'Mechanic Contact No': mechanicModel?.mechanicNumber ?? "",
                'Address': mechanicModel?.address ?? "",
                'Workshop Segment': mechanicModel?.outletSegment,
                'Mechanic Segment?': mechanicModel?.outletSegment,
                'Outlet Name': mechanicModel?.outletName ?? "",
                'Outlet Address': mechanicModel?.address ?? "",
                'Workshop Name': mechanicModel?.outletName ?? "",
                'Workshop Address': mechanicModel?.address ?? "",
                'Workshop Image': mechanicModel?.outletImage ?? "",
                'District': mechanicModel?.district ?? "",
                'Pincode': mechanicModel?.pin ?? "",
                'Outlet Image': mechanicModel?.outletImage ?? "",
                'Mechanic Image': mechanicModel?.image ?? "",
              };

    mechanicSubQuestions.forEach((question, value) {
      if (event.index >= 0) {
        segmentList[event.index]
            .questionAnswers
            .firstWhereOrNull(
                (element) => element.question.isSameWord(question))
            ?.answer = value;

        if (segmentList[event.index]
                .questionAnswers
                .firstWhereOrNull(
                    (element) => element.question.isSameWord(question))
                ?.answer
                ?.trim()
                .isNotEmpty ??
            false) {
          segmentList[event.index]
              .questionAnswers
              .firstWhereOrNull(
                  (element) => element.question.isSameWord(question))
              ?.isEditable = false;
        }
      } else {
        questionAnswers
            .firstWhereOrNull(
                (element) => element.question.isSameWord(question))
            ?.answer = value;

        if (questionAnswers
                .firstWhereOrNull(
                    (element) => element.question.isSameWord(question))
                ?.answer
                ?.trim()
                .isNotEmpty ??
            false) {
          questionAnswers
              .firstWhereOrNull(
                  (element) => element.question.isSameWord(question))
              ?.isEditable = false;
        } else {
          questionAnswers
              .firstWhereOrNull(
                  (element) => element.question.isSameWord(question))
              ?.isEditable = true;
        }
      }
    });
  }

  Future<void> _setRecruiterAnswers(
      bool existingRecCase, int orderIndex) async {
    RecruiterModel? recruiterModel;
    if (existingRecCase) {
      String selectedRetailerOption = questionAnswers
              .firstWhereOrNull((element) =>
                  [
                    "Retailer/Workshop Name".toLowerCase(),
                    'select retailer',
                    'select revisit retailer',
                    "retailer name",
                    "which retailer are you buying from?",
                    "add outlet name"
                  ].contains(element.question.trim().toLowerCase()) &&
                  element.questionOrder == orderIndex)
              ?.answer ??
          "";
      if (["master data","mechanic visit"].contains(selectedCampaign?.name.toLowerCase())) {
        recruiterModelList.clear();
      }
      if (selectedRetailerOption.contains(",")) {
        List<String> selectValue = selectedRetailerOption.split(",");
        List<RecruiterModel> recruiterList = [];
        for (String value in selectValue) {
          RecruiterModel? recruiterModelValue = recs.firstWhereOrNull(
              (element) => element.counterName.isSameWord(value));
          if (recruiterModelValue != null) {
            recruiterList.add(recruiterModelValue);
          }
        }
        recruiterModelList = recruiterList;
      } else {
        recruiterModel = recs.firstWhereOrNull((element) =>
            element.counterName.isSameWord(selectedRetailerOption));

        if (recruiterModel != null) {
          recruiterModelList.add(recruiterModel);
        }
      }
    }
    if ([
      'master data',
      "mechanic visit",
      'mobil miles mechanic registration',
      'mobil miles mechanic redemption'
    ].contains(selectedCampaign?.name.trim().toLowerCase())) {
      return;
    }

    Map<String, String?> recruiterSubQuestions =
        (selectedCampaign?.name.trim().toLowerCase() == "isp" &&
                orderIndex >= 4)
            ? {
                'Name': recruiterModel?.counterName ?? "",
                "Contact No.": recruiterModel?.contactNumber ?? "",
              }
            : {
                'Counter Name': recruiterModel?.counterName ?? "",
                'Contact person Name': recruiterModel?.counterPerson ?? "",
                'Retailer Contact Person Name':
                    recruiterModel?.counterPerson ?? "",
                'Retailer/Workshop Contact Person Name':
                    recruiterModel?.counterPerson ?? "",
                'Contact Number': recruiterModel?.contactNumber ?? "",
                'Retailer Contact Number': recruiterModel?.contactNumber ?? "",
                'Retailer/Workshop Contact Number':
                    recruiterModel?.contactNumber ?? "",
                'Retailer Outlet Name': recruiterModel?.counterName ?? "",
                'Outlet Name ': recruiterModel?.counterName ?? "",
                'Workshop Name': recruiterModel?.counterName ?? "",
                'Contact Address': recruiterModel?.address ?? "",
                'Address': recruiterModel?.address ?? "",
                'Outlet Address': recruiterModel?.address ?? "",
                'Workshop Address': recruiterModel?.address ?? "",
                'Retailer Outlet Address': recruiterModel?.address ?? "",
                'Retailer/Workshop Outlet Address':
                    recruiterModel?.address ?? "",
                'GCIN Code': recruiterModel?.gcinCode ?? "",
                'ISP segment': recruiterModel?.outletSegment,
                'Retailer Pincode': recruiterModel?.pin ?? "",
                'Retailer/Workshop Pincode': recruiterModel?.pin ?? "",
                'Pincode': recruiterModel?.pin ?? "",
                "Retailer District": recruiterModel?.district ?? "",
                "Retailer/Workshop District": recruiterModel?.district ?? "",
                "District": recruiterModel?.district ?? "",
                'upload photo': recruiterModel?.image ?? "",
                'upload image': recruiterModel?.image ?? "",
                'Outlet Image ': recruiterModel?.image ?? "",
                'Workshop Image': recruiterModel?.image ?? "",
                'Retailer upload photo': recruiterModel?.image ?? "",
              };

    recruiterSubQuestions.forEach((question, value) {
      questionAnswers
          .firstWhereOrNull((element) => element.question.isSameWord(question))
          ?.answer = value;

      if (questionAnswers
              .firstWhereOrNull(
                  (element) => element.question.isSameWord(question))
              ?.answer
              ?.trim()
              .isNotEmpty ??
          false) {
        questionAnswers
            .firstWhereOrNull(
                (element) => element.question.isSameWord(question))
            ?.isEditable = false;
      } else {
        questionAnswers
            .firstWhereOrNull(
                (element) => element.question.isSameWord(question))
            ?.isEditable = true;
      }
    });
  }

  bool _sectionRuleMatches(SectionRule rule, CampaignQuestionModel trigger) {
    final compareAnswer = (trigger.answer?.split(',') ?? <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final ruleAnswers = rule.answer
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (trigger.inputTypeValidation == "MULTI_SELECT_CHECKBOX" ||
        trigger.inputTypeValidation == "MULTI_SELECT_DROPDOWN") {
      return hasCommonIgnoreCase(compareAnswer, ruleAnswers);
    }

    return compareAnswer.contains(rule.answer) ||
        trigger.answer?.trim().toLowerCase() ==
            rule.answer.trim().toLowerCase();
  }

  CampaignQuestionModel? _findTriggerQuestionForSectionRule(SectionRule rule) {
    final sectionsToSearch = rule.sectionUuid.isEmpty
        ? allCampSections
        : allCampSections.where((s) => s.uuid == rule.sectionUuid).toList();

    for (final section in sectionsToSearch) {
      final question = section.selectedSectionQuestions
          .firstWhereOrNull((q) => q.uuid == rule.questionUuid);
      if (question != null) return question;
    }
    return null;
  }

  bool _isSectionVisible(CampaignQuestionSectionModel section) {
    if (section.rules.isEmpty) return true;

    return section.rules.any((rule) {
      final trigger = _findTriggerQuestionForSectionRule(rule);
      if (trigger == null) return false;
      return _sectionRuleMatches(rule, trigger);
    });
  }

  void _updateVisibleSections({bool switchSectionIfHidden = true}) {
    selectedCampSections =
        allCampSections.where(_isSectionVisible).toList();

    if (switchSectionIfHidden &&
        selectedCampSections.isNotEmpty &&
        !selectedCampSections
            .any((s) => s.uuid == lastSelectedSectionUuid)) {
      lastSelectedSectionUuid = selectedCampSections.first.uuid;
      add(GetQuestionsForSection(sectionUuId: lastSelectedSectionUuid));
    }
  }

  void _updateQuestionModelWithRule() {
    var lastSelectedQuestions = allCampSections
        .firstWhereOrNull((element) => element.uuid == lastSelectedSectionUuid)
        ?.selectedSectionQuestions;
    if (lastSelectedQuestions == null) return;
    questionAnswers = _getQuestionsAccordingToGivenAnswers(
            _findValidCampaignQuestion(lastSelectedQuestions))
        .map((e) => e.toViewQuestionModel())
        .toList();
    questionAnswers.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
    lastSelectedQuestions
        .map((toElement) => {
              if (!questionAnswers
                  .any((question) => question.uuid == toElement.uuid))
                {
                  toElement.answer = null,
                  toElement.issuesImage = null,
                  toElement.issuesImage = null
                }
            })
        .toList();
  }

  List<CampaignQuestionModel> _getQuestionsAccordingToGivenAnswers(
      List<CampaignQuestionModel> lastSelectedQuestions) {
    List<CampaignQuestionModel> newquestionsList = [];
    for (var question in lastSelectedQuestions) {
      if (question.rules.isEmpty) {
        newquestionsList.add(question);
      } else {
        final rule = question.rules.first;
        final compareQuestion = newquestionsList
            .firstWhereOrNull((q) => q.uuid == rule.questionUuid);
        List<String> compareAnswer =
            (compareQuestion?.answer?.split(',') ?? <String>[]);
        for (var element in compareAnswer) {
          element.trim();
        }
        if ((compareQuestion?.inputTypeValidation ?? "") ==
                "MULTI_SELECT_CHECKBOX" ||
            (compareQuestion?.inputTypeValidation ?? "") ==
                "MULTI_SELECT_DROPDOWN") {
          if (hasCommonIgnoreCase(compareAnswer, rule.answer.split(","))) {
            newquestionsList.add(question);
          }

          //  else if (compareQuestion?.answer?.trim().toLowerCase() ==
          //     rule.answer.trim().toLowerCase()) {
          //   newquestionsList.add(question);
          // }
        } else {
          if (compareAnswer.contains(rule.answer)) {
            newquestionsList.add(question);
          } else if (compareQuestion?.answer?.trim().toLowerCase() ==
              rule.answer.trim().toLowerCase()) {
            newquestionsList.add(question);
          }
        }
      }
    }
    return newquestionsList;
  }

  // ========== OFFLINE SUPPORT METHODS ==========

  // Sync offline submissions (background version without emitter)
  Future<void> _syncOfflineSubmissionsBackground({bool bySync = false}) async {
    // This version doesn't emit states - used for background sync
    final isOnline = await _offlineService.isOnline();
    if (!isOnline) return;

    final pending = await _offlineService.getPendingSubmissions();
    if (pending.isEmpty) return;

    int successCount = 0;
    int failCount = 0;

    for (var submission in pending) {
      try {
        await _offlineService.updateSubmissionStatus(
          submission['id'],
          'processing',
        );

        // Process images in the request body before submission
        // During sync, all images must be uploaded successfully (throwOnImageUploadFailure: true)
        final requestBody = await _processImagesInRequestBody(
          submission['requestBody'] as Map<String, dynamic>,
          throwOnImageUploadFailure:
              true, // Fail fast if image upload fails during sync
        );

        // Add bySync flag to request body
        requestBody['bySync'] = bySync;

        final score = await repo.saveCampaignAnswers(requestBody);

        if (score.uuId.isNotEmpty) {
          // Handle additional operations
          if (submission['masterData'] != null) {
            await _executeMasterData(
                submission['masterData'] as Map<String, dynamic>);
          }
          if (submission['mechanicData'] != null) {
            await _executeMechanicData(
                submission['mechanicData'] as Map<String, dynamic>);
          }
          if (submission['retailerVisitData'] != null) {
            await _executeRetailerVisitData(
                submission['retailerVisitData'] as Map<String, dynamic>);
          }
          if (submission['segmentData'] != null) {
            await _executeSegmentData(
              submission['segmentData'] as List<dynamic>,
              score.uuId,
              submission['campaignUuid'] as String,
            );
          }

          await _offlineService.removeSubmission(submission['id']);
          successCount++;
        }
      } catch (e) {
        await _offlineService.updateSubmissionStatus(
          submission['id'],
          'failed',
          error: e.toString(),
        );
        failCount++;
      }
    }

    // Log for background sync
    if (bySync) {
      debugPrint(
          '✅ Auto-synced campaigns: $successCount success, $failCount failed');
    }
  }

  // Sync offline submissions when online (with emitter for manual sync)
  Future<void> _syncOfflineSubmissions(Emitter<CampaignState> emit,
      {bool bySync = false}) async {
    final isOnline = await _offlineService.isOnline();
    if (!isOnline) {
      if (!bySync) {
        // Only show message for manual sync
        emit(SnackbarMessageCampaignState(
            "No internet connection. Cannot sync."));
      }
      return;
    }

    final pending = await _offlineService.getPendingSubmissions();
    if (pending.isEmpty) {
      if (!bySync) {
        // Only show message for manual sync
        emit(SnackbarMessageCampaignState("No pending submissions to sync."));
      }
      return;
    }

    // Only emit loading state for manual sync (not blocking for auto sync)
    if (!bySync) {
      emit(SyncingOfflineDataState(pending.length));
    }

    int successCount = 0;
    int failCount = 0;

    for (var submission in pending) {
      try {
        await _offlineService.updateSubmissionStatus(
          submission['id'],
          'processing',
        );

        // Process images in the request body before submission
        // During sync, all images must be uploaded successfully (throwOnImageUploadFailure: true)
        final requestBody = await _processImagesInRequestBody(
          submission['requestBody'] as Map<String, dynamic>,
          throwOnImageUploadFailure:
              true, // Fail fast if image upload fails during sync
        );

        // Add bySync flag to request body
        requestBody['bySync'] = bySync;

        final score = await repo.saveCampaignAnswers(requestBody);

        if (score.uuId.isNotEmpty) {
          // Handle additional operations
          if (submission['masterData'] != null) {
            await _executeMasterData(
                submission['masterData'] as Map<String, dynamic>);
          }
          if (submission['mechanicData'] != null) {
            await _executeMechanicData(
                submission['mechanicData'] as Map<String, dynamic>);
          }
          if (submission['retailerVisitData'] != null) {
            await _executeRetailerVisitData(
                submission['retailerVisitData'] as Map<String, dynamic>);
          }
          if (submission['segmentData'] != null) {
            await _executeSegmentData(
              submission['segmentData'] as List<dynamic>,
              score.uuId,
              submission['campaignUuid'] as String,
            );
          }
          await _offlineService.removeSubmission(submission['id']);
          successCount++;
        }
      } catch (e) {
        await _offlineService.updateSubmissionStatus(
          submission['id'],
          'failed',
          error: e.toString(),
        );
        failCount++;
      }
    }
    // Only show messages for manual sync (not blocking for auto sync)
    if (!bySync) {
      if (successCount > 0 && failCount == 0) {
        emit(SnackbarMessageCampaignState(
            "All $successCount submission(s) synced successfully"));
      } else if (successCount > 0) {
        emit(SnackbarMessageCampaignState(
            "$successCount synced, $failCount failed"));
      } else {
        emit(SnackbarMessageCampaignState(
            "Failed to sync submissions. Please try again."));
      }
    } else {
      // Auto sync - just log, don't block UI
      debugPrint(
          '✅ Auto-synced campaigns: $successCount success, $failCount failed');
    }
  }

  List<CampaignQuestionModel> _findValidCampaignQuestion(
      List<CampaignQuestionModel> ques) {
    if (selectedCampaign?.name.toLowerCase() == 'isp') {
      List<String> filterQuestion = [
        "competition brand sold",
        'remark',
        'upload photo',
        "castrol pack sold",
        "shell pack sold",
        "gulf pack sold",
        "valvoline pack sold",
        "motul pack sold",
        "total pack sold",
        "veedol pack sold",
      ];

      return ques
          .where(
              (q) => !filterQuestion.contains(q.question.toLowerCase().trim()))
          .toList();
    }
    return ques;
  }

  // Process images in request body - convert local paths to URLs
  // During sync, all images must be uploaded successfully - throws exception if upload fails
  Future<Map<String, dynamic>> _processImagesInRequestBody(
    Map<String, dynamic> requestBody, {
    bool throwOnImageUploadFailure =
        true, // During sync, we must upload all images
  }) async {
    final campaignResponse = requestBody['campaignResponse'] as List<dynamic>;
    final List<Map<String, dynamic>> processedResponse = [];
    final List<String> failedImagePaths = [];

    for (final section in campaignResponse) {
      final sectionMap = section as Map<String, dynamic>;
      final questions = sectionMap['questions'] as List<dynamic>;
      final List<Map<String, dynamic>> processedQuestions = [];

      for (final question in questions) {
        final questionMap = question as Map<String, dynamic>;
        final processedQuestion = Map<String, dynamic>.from(questionMap);

        // Process main answer for image questions
        if (questionMap['questionDataType'] == 'image' ||
            questionMap['questionDataType'] == 'IMAGE') {
          final answer = questionMap['answer'] as String?;
          if (answer != null && answer.isNotEmpty && !answer.urlValid()) {
            try {
              processedQuestion['answer'] = await repo.getImageUrlPath(answer);
            } catch (e) {
              if (throwOnImageUploadFailure) {
                // During sync, image upload failure is critical
                failedImagePaths.add(answer);
                debugPrint('Failed to upload image: $answer - $e');
              } else {
                // Keep original if upload fails (offline mode during submission)
                processedQuestion['answer'] = answer;
              }
            }
          }
        }
        // Process issuesImage
        final issuesImage = questionMap['issuesImage'] as String?;
        if (issuesImage != null && issuesImage.isNotEmpty) {
          final imagePaths = issuesImage.split(",");
          final List<String> uploadedImageUrls = [];

          for (final imagePath in imagePaths) {
            final trimmedPath = imagePath.trim();
            if (trimmedPath.isNotEmpty) {
              if (trimmedPath.urlValid()) {
                uploadedImageUrls.add(trimmedPath);
              } else {
                try {
                  final url = await repo.getImageUrlPath(trimmedPath);
                  uploadedImageUrls.add(url);
                } catch (e) {
                  if (throwOnImageUploadFailure) {
                    // During sync, image upload failure is critical
                    failedImagePaths.add(trimmedPath);
                    debugPrint(
                        'Failed to upload issues image: $trimmedPath - $e');
                  } else {
                    // Keep original if upload fails (offline mode during submission)
                    uploadedImageUrls.add(trimmedPath);
                  }
                }
              }
            }
          }

          processedQuestion['issuesImage'] = uploadedImageUrls.join(",");
        }

        processedQuestions.add(processedQuestion);
      }

      processedResponse.add({
        ...sectionMap,
        'questions': processedQuestions,
      });
    }

    // If any images failed to upload during sync, throw exception
    if (throwOnImageUploadFailure && failedImagePaths.isNotEmpty) {
      throw Exception(
          'Failed to upload ${failedImagePaths.length} image(s) during sync. '
          'Please ensure you have a stable internet connection. '
          'Failed images: ${failedImagePaths.take(3).join(", ")}${failedImagePaths.length > 3 ? "..." : ""}');
    }

    return {
      ...requestBody,
      'campaignResponse': processedResponse,
    };
  }

  // Helper methods to prepare data for offline queue
  Future<Map<String, dynamic>> _prepareMasterData(
      Map<String, Object> reqBody) async {
    final questList = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .first['questions'] as List<Map<String, dynamic>>;

    answerFor(String questionName) => questList.firstWhereOrNull((element) =>
        element['questionName']?.toString().trim().isSameWord(questionName) ??
        false)?['answer'];

    if ((answerFor("Type") ?? "")
        .toString()
        .trim()
        .toLowerCase()
        .contains('Retailer'.toLowerCase())) {
      return {
        'type': 'retailer',
        'data': {
          "retailerName": answerFor("Retailer/Workshop Name") ??
              answerFor("Retailer Name") ??
              "",
          "counterName":
              answerFor("Workshop Name") ?? answerFor("Outlet Name") ?? "",
          "counterPerson": answerFor("Contact Person Name") ?? "",
          "contactNumber": answerFor('Contact Number') ?? '',
          "address": answerFor('Workshop Address') ??
              answerFor('Outlet Address') ??
              '',
          "pin": answerFor('Pincode') ?? '',
          "district": answerFor('District') ?? '',
          "state": answerFor('State') ?? '',
          "image": answerFor('Counter Image') ?? '',
          "outletSegment": answerFor('Workshop Segment') ??
              answerFor('Outlet Segment') ??
              '',
          "mappedTo": (AppStorage().userDetail?.id ?? 1).toString()
        }
      };
    } else if ((answerFor("Type") ?? "")
        .trim()
        .toLowerCase()
        .contains('Mechanic'.toLowerCase())) {
      return {
        'type': 'mechanic',
        'data': {
          "mechanicName": answerFor('Mechanic Name') ?? "",
          "mechanicNumber": answerFor('Mechanic Contact No') ?? "",
          "outletName":
              answerFor('Workshop Name') ?? answerFor('Outlet Name') ?? '',
          "address": answerFor('Workshop Address') ??
              answerFor('Outlet Address') ??
              '',
          "pin": answerFor('Pincode') ?? '',
          "district": answerFor('District') ?? '',
          "state": answerFor('State') ?? '',
          "image":
              answerFor('Mechanic image') ?? answerFor('upload image') ?? "",
          "outletImage": answerFor('Workshop image') ??
              answerFor('Outlet image') ??
              answerFor('upload image') ??
              "",
          "outletSegment": answerFor('Workshop Segment') ??
              answerFor('Outlet Segment') ??
              '',
          "mappedTo": (AppStorage().userDetail?.id ?? 1).toString()
        }
      };
    }
    return {};
  }

  Future<Map<String, dynamic>> _prepareMechanicData(
      Map<String, Object> reqBody) async {
    final questList = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .first['questions'] as List<Map<String, dynamic>>;

    answerFor(String questionName) => questList.firstWhereOrNull((element) =>
        element['questionName']?.toString().trim().isSameWord(questionName) ??
        false)?['answer'];

    String answer = answerFor("Select Mechanics") ?? "";
    String id = (mechanics
                .firstWhereOrNull((mechanic) =>
                    answer ==
                    "${mechanic.mechanicName}-${mechanic.mechanicNumber}")
                ?.id ??
            "")
        .toString();

    bool isActivation =
        (reqBody['campaignResponse'] as List<Map<String, Object>>).any(
            (element) =>
                element["sectionName"].toString().toLowerCase() ==
                "Mechanic Activation".toLowerCase());

    return {
      'id': id,
      'isActivated': isActivation,
      'isEnrolled': !isActivation,
    };
  }

  Future<Map<String, dynamic>> _prepareRetailerVisitData(
      Map<String, Object> reqBody) async {
    final questList = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .first['questions'] as List<Map<String, dynamic>>;

    answerFor(String questionName) => questList.firstWhereOrNull((element) =>
        element['questionName']?.toString().trim().isSameWord(questionName) ??
        false)?['answer'];

    return {
      "type": (answerFor("Type of account ") ?? "")
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll(RegExp('\\s+'), ''),
      "retailerName": answerFor("Retailer/Workshop Name") ??
          answerFor("Retailer Name ") ??
          "",
      "retailerContactNo": answerFor("Contact Number ") ?? "",
      "outletName":
          answerFor("Workshop Name ") ?? answerFor("Outlet Name ") ?? "",
      "detailAddress": answerFor("Address") ?? "",
      "outletImage":
          answerFor("Workshop Image ") ?? answerFor("Outlet Image ") ?? "",
      "outletSegment": answerFor("Select Segment ") ?? "",
      "isOrderConfirmed": answerFor("Is an order confirmed ?") ?? "",
      "userId": (AppStorage().userDetail?.id ?? 1).toString()
    };
  }

  Future<List<dynamic>> _prepareSegmentData(Map<String, Object> reqBody) async {
    final isOsmm = (reqBody['campaignResponse'] as List<Map<String, Object>>)
        .any((element) => ["osmm", "isp", "record sales"]
            .contains(element["sectionName"].toString().toLowerCase()));

    if (!isOsmm) return [];

    Map<String, dynamic> section =
        (reqBody['campaignResponse'] as List<Map<String, Object>>).firstWhere(
            (element) => ["osmm", "isp", 'record sales']
                .contains(element["sectionName"].toString().toLowerCase()));
    final campaignUuid = reqBody['campaignUuid'];

    List<dynamic> request = [];
    int groupIndex = 0;
    for (SegmentModel element in segmentList) {
      int index = 0;
      List<CampaignQuestionModel> questionList = [];
      while (index < element.questionAnswers.length) {
        questionList.add(element.questionAnswers[index].campQuestionModel!);
        questionList[index].answer = element.questionAnswers[index].answer;
        index++;
      }
      request.add({
        'groupname': "$groupIndex",
        'sectionUuid': section["sectionUuid"],
        'campaignUuid': campaignUuid.toString(),
        'group': questionList.map((q) => q.toJson()).toList(),
      });
      groupIndex++;
    }
    return request;
  }

  // Execute methods for syncing
  Future<void> _executeMasterData(Map<String, dynamic> masterData) async {
    if (masterData['type'] == 'retailer') {
      await repo.saveRecruiter(Map<String, String>.from(masterData['data']));
    } else if (masterData['type'] == 'mechanic') {
      await repo.saveMechanic(Map<String, String>.from(masterData['data']));
    }
  }

  Future<void> _executeMechanicData(Map<String, dynamic> mechanicData) async {
    final id = mechanicData['id'] as String;
    final bodyMap = <String, dynamic>{};
    if (mechanicData['isActivated'] == true) {
      bodyMap['isActivated'] = true;
    } else if (mechanicData['isEnrolled'] == true) {
      bodyMap['isEnrolled'] = true;
    }
    if (bodyMap.isNotEmpty) {
      await repo.saveActivationOrEnrolment(bodyMap, id);
    }
  }

  Future<void> _executeRetailerVisitData(
      Map<String, dynamic> retailerVisitData) async {
    await repo.saveRetailerVisit(Map<String, String>.from(retailerVisitData));
  }

  Future<void> _executeSegmentData(
      List<dynamic> segmentData, String uuId, String campaignUuid) async {
    if (segmentData.isEmpty) return;

    final request = segmentData.map((item) {
      return {
        'groupname': item['groupname'],
        'sectionUuid': item['sectionUuid'],
        'campaignUuid': item['campaignUuid'],
        'group': item['group'],
      };
    }).toList();

    await repo.addSagment(request, campaignUuid, storeId, uuId);
  }
}

bool hasCommonIgnoreCase(List<String> a, List<String> b) {
  final setB = b.map((e) => e.toLowerCase()).toSet();

  return a.any((e) => setB.contains(e.toLowerCase()));
}

extension Compare on String {
  bool isSameWord(String? b) {
    return trim().toLowerCase() == b?.trim().toLowerCase();
  }
}
