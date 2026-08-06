import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_model.dart';
import 'package:i_densfa/module/survey_module/models/filled_survey_response_model.dart';
import 'package:i_densfa/module/survey_module/models/survey_scheduled_visit_model.dart';
import 'package:i_densfa/module/survey_module/survey_repository.dart';
import 'package:i_densfa/module/survey_module/models/survey_form_question_model.dart';
import 'package:i_densfa/module/survey_module/models/survey_form_section_model.dart';
import 'package:i_densfa/module/survey_module/models/survey_model.dart';
import 'package:i_densfa/routes.dart';
import 'package:i_densfa/utility/continuous_location_service.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:image_picker/image_picker.dart';
part 'survey_event.dart';
part 'survey_state.dart';

class SurveyBloc extends Bloc<SurveyEvent, SurveyState> {
  final repo = SurveyRepository();
  String? surveyUuid;
  int pageOffset = 0;
  int totalPages = 0;
  ScrollController controller = ScrollController();
  List<SurveyListItemModel> surveyList = [];
  List<SurveyFormSectionModel> selectedSurveyFormSections = [];
  SurveyListItemModel? selectedSurvey;
  SurveyDetailModel? savedSurveyDetails;
  var lastSelectedSectionUuid = '';
  var clientNameForQuestionnaire = '';

  var surveyClientList = <String>[];
  var formEditting = false;
  bool isloadingNext = false;
  // FilledSurveyResponse? filledSurveyResponse;
  List<FilledSurveyUserResponse> filledSurveyUserResponse = [];
  List<FilledSurveyUserResponse> surveyUserResponse = [];
  FilledSurveyApiResponse? response;
  FilledSurveyUserResponse? selectedSurveyUserResponse;
  List<QuestionModel> questionAnswers = [];
  List<StoreNoteModel> surveyNotesList = [];
  List<SurveyScheduledVisitModel> scheduledVisits = [];
  var schedileListDate = DateTime.now();
  XFile? clientfile;
  SurveyBloc() : super(SurveyInitial()) {
    controller.addListener(_scrollListener);
    on(_onAnswerUpdatedSurveyEvent);
    on(_uploadImageEvent);
    on(_onCreateNotesEvent);
    on(_onGetNotesEvent);
    on(_onDeleteNotesEvent);
    on(_onGetSurveyVisitEvent);
    on(_onCreateSurveyVisitEvent);
    on(_onGetClientEvent);
    on(_onGetSurveysEvent);
    on(_onGetSurveysSections);
    on(_onGetQuestionsForSection);
    on(_onSaveSurveyAnswersEvent);
    on(_onCompleteSurveyFormEvent);
    on(_onGetFilledSurveys);
    on(_onGetNextFilledSurveys);
    on((SurveyClientNameAdded event, emit) {
      clientNameForQuestionnaire = event.name;
      clientfile = event.clientfile;
    });

    on(_onSurveySearchEvent);

    on((SurveyVisitsDateChangeEvent event, emit) {
      schedileListDate = event.date;
      add(GetSurveyVisitEvent());
    });

    on((ChangeStateEvent event, emit) => emit(OptionChangeState()));

    on((SnackbarMessageSurveyEvent event, emit) =>
        emit(SnackbarMessageSurveyState(event.message)));
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      add(GetNextFilledSurveysEvent(surveyUuid: surveyUuid ?? ""));
    }
  }

  String getIdList(
    List<String> listAttribute,
  ) {
    String ides = "";
    int index = 0;
    while (index < listAttribute.length) {
      if (ides.isEmpty) {
        ides = listAttribute[index];
      } else {
        ides = "${listAttribute[index]},$ides";
      }
      index++;
    }

    return ides;
  }

  void _onSurveySearchEvent(SurveyListSearchEvent event, emit) {
    if (event.seachText.trim().isEmpty) {
      filledSurveyUserResponse = surveyUserResponse;
    } else {
      filledSurveyUserResponse = surveyUserResponse
          .where((element) =>
              element.clientName
                  .toLowerCase()
                  .contains(event.seachText.toLowerCase()) ||
              element.createdDate
                  .toStringFormat("dd/MM/yyyy")
                  .toLowerCase()
                  .contains(event.seachText.toLowerCase()) ||
              element.questionResponse.any((qutelement) =>
                  qutelement.isActive &&
                  qutelement.answer
                      .toLowerCase()
                      .contains(event.seachText.toLowerCase())))
          .toList();
    }
    emit(SurveyInitial());
  }

  void _onGetNextFilledSurveys(GetNextFilledSurveysEvent event, emit) async {
    try {
      pageOffset++;
      if (pageOffset > totalPages) {
        pageOffset = totalPages;
        return;
      } else if (pageOffset < 0) {
        pageOffset = 0;
      } else {
        pageOffset = pageOffset = pageOffset;
      }
      isloadingNext = true;
      response = await repo.getFilledSurveys(event.surveyUuid, pageOffset);
      totalPages = response?.totalPages ?? 0;
      isloadingNext = false;
      surveyUserResponse.addAll(response?.surveyResponse.userResponse ?? []);
      filledSurveyUserResponse
          .addAll(response?.surveyResponse.userResponse ?? []);
      emit(SurveyInitial());
    } catch (e) {
      isloadingNext = false;
      emit(SnackbarMessageSurveyState(e.toString()));
    }
  }

  void _onGetFilledSurveys(GetFilledSurveysEvent event, emit) async {
    try {
      filledSurveyUserResponse = [];
      pageOffset = 0;
      surveyUuid = event.surveyUuid;
      response = await repo.getFilledSurveys(event.surveyUuid, pageOffset);
      totalPages = response?.totalPages ?? 0;
      filledSurveyUserResponse = response?.surveyResponse.userResponse ?? [];
      surveyUserResponse = response?.surveyResponse.userResponse ?? [];
      emit(SurveyInitial());
    } catch (e) {
      emit(SnackbarMessageSurveyState(e.toString()));
    }
  }

  void _onCompleteSurveyFormEvent(CompleteSurveyFormEvent event, emit) async {
    selectedSurveyFormSections =
        (await repo.getSections(surveyUuid: selectedSurvey!.uuid));
    selectedSurveyFormSections
        .sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    if (selectedSurveyFormSections.isEmpty) {
      add(SnackbarMessageSurveyEvent(message: 'No Questions added.'));
      return;
    } else {
      add(GetQuestionsForSection(
          sectionUuId: selectedSurveyFormSections[0].uuid));
    }
    formEditting = event.editPrevious;
    for (var element in questionAnswers) {
      element.answer = null;
    }
    emit(SurveyNavigateState(named: AppPaths.surveyForm));
  }

  void _onSaveSurveyAnswersEvent(SaveSurveyAnswersEvent event, emit) async {
    saveAnswersForSelectedSection();

    final unAnsweredSection = selectedSurveyFormSections.firstWhereOrNull(
        (element) => element.selectedSectionQuestions.isEmpty);
    if (unAnsweredSection != null) {
      emit(SnackbarMessageSurveyState(
          "Please answer for Section: ${unAnsweredSection.name}"));
      return;
    }

    final notAnsweredQuestions = _totalNotAnsweredQuestions();

    if (notAnsweredQuestions.isNotEmpty) {
      emit(SnackbarMessageSurveyState(
          "Please answer for ${notAnsweredQuestions.first.question}"));
      return;
    }

    if (!_checkValidations(emit)) return;
    emit(SavingAnswersLoadingState());
    try {
      final reqBody = await _getSubmitRequestBody();
      final uriId = formEditting
          ? selectedSurveyUserResponse?.uuid ?? ''
          : reqBody['surveyUuid'].toString();
      final score = await repo.saveSurveyAnswers(reqBody, formEditting, uriId);
      if (score) {
        // add(GetSavedSurveyResponseEvent(selectedSurvey!.uuid));
        emit(SnackbarMessageSurveyState("Saved Successfully"));
        emit(ScoreCalculatedSurveyState());
      }
    } catch (error) {
      emit(SnackbarMessageSurveyState(error.toString()));
    }
  }

  void _onGetQuestionsForSection(GetQuestionsForSection event, emit) async {
    saveAnswersForSelectedSection();
    lastSelectedSectionUuid = event.sectionUuId;
    var questions = selectedSurveyFormSections
        .firstWhere((element) => element.uuid == event.sectionUuId)
        .selectedSectionQuestions;
    questionAnswers.clear();
    emit(SurveyQuestionsLoadedState());
    if (questions.isEmpty) {
      emit(SurveyListLoadingState());
      questions = await repo.getQuestions(
          surveyUuid: selectedSurvey?.uuid ?? "",
          sectionUuid: event.sectionUuId);

      if (questions.any((element) =>
          element.question.trim().toLowerCase() == "select promoter")) {
        List<String> data = await repo.getPromoter();
        String otion = data.join(",");
        questions
            .where((element) =>
                element.question.trim().toLowerCase() == "select promoter")
            .forEach((element) {
          element.options = otion;
        });
      }
      if (questions.any((element) =>
          selectedSurvey?.name.trim().toLowerCase() == "on call data info" &&
          element.question.trim().toLowerCase() == "state name")) {
        List<String> data = await repo.getOncallState();
        String otion = data.join(",");
        questions
            .where((element) =>
                element.question.trim().toLowerCase() == "state name")
            .forEach((element) {
          element.options = otion;
        });
      }

      if (questions.any((element) =>
          selectedSurvey?.name.trim().toLowerCase() == "on call data info" &&
          element.question.trim().toLowerCase() == "brand")) {
        List<String> data = await repo.getOncallBrand();
        String otion = data.join(",");
        questions
            .where(
                (element) => element.question.trim().toLowerCase() == "brand")
            .forEach((element) {
          element.options = otion;
        });
      }

      if (questions.any((element) =>
          element.question.trim().toLowerCase() ==
          "village name/area of working")) {
        List<String> data = await repo.getCity();
        String otion = data.join(",");
        questions
            .where((element) =>
                element.question.trim().toLowerCase() ==
                "village name/area of working")
            .forEach((element) {
          element.options = otion;
        });
      }
      // getting saved answers if survey is previously filled
      questions.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
      if (formEditting) {
        try {
          final savedAnswers = await repo.getSavedQuestions(
              selectedSurvey!.uuid,
              event.sectionUuId,
              selectedSurveyUserResponse?.uuid ?? "");
          for (var question in questions) {
            final savedAnswer = savedAnswers
                .firstWhereOrNull(
                    (element) => element.questionUuid == question.uuid)
                ?.answer;
            // making sure if user hasn't changed answer
            if (question.answer?.trim().isEmpty ?? true) {
              question.answer = savedAnswer;
            }
          }
        } catch (e) {
          rethrow;
        }
      }

      // merging updated question and answers with sections
      selectedSurveyFormSections
          .firstWhere((element) => element.uuid == event.sectionUuId)
          .selectedSectionQuestions = questions;
    }
    _updateQuestionModelWithRule();
    emit(SurveyQuestionsLoadedState());
  }

  void _onGetSurveysSections(GetSurveySections event, emit) async {
    // add(GetSavedSurveyResponseEvent(event.campUuId));
    selectedSurveyFormSections =
        (await repo.getSections(surveyUuid: event.surveyUuId));
    selectedSurveyFormSections
        .sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    if (selectedSurveyFormSections.isNotEmpty) {
      add(GetQuestionsForSection(
          sectionUuId: selectedSurveyFormSections[0].uuid));
    }
  }

  void _onGetSurveysEvent(GetSurveysEvent event, emit) async {
    try {
      emit(SurveyListLoadingState());
      surveyList = await repo.getSurveys();
      emit(SurveyListLoadedState());
    } catch (e) {
      emit(SnackbarMessageSurveyState(e.toString()));
    }
  }

  void _onGetClientEvent(GetClientEvent event, emit) async {
    try {
      surveyClientList = await repo.getClient(selectedSurvey!.uuid);
    } catch (e) {
      emit(SnackbarMessageSurveyState(e.toString()));
    }
  }

  void _onCreateSurveyVisitEvent(CreateSurveyVisitEvent event, emit) async {
    emit(SurveyScheduleLoadingState());
    var isCreate = await repo.scheduleSurveysVisit(
        selectedSurvey!.uuid, event.clientName, event.visitDate, event.agenda);
    if (isCreate) {
      emit(SurveyScheduleSuccessState());
      emit(SnackbarMessageSurveyState('Survey Schedule successfully'));
    } else {
      emit(SnackbarMessageSurveyState('Failed to Schedule Survey'));
    }
  }

  void _onGetSurveyVisitEvent(GetSurveyVisitEvent event, emit) async {
    try {
      scheduledVisits = await repo.getSurveyScheduledVisits(
          schedileListDate, selectedSurvey!.uuid);
      emit(SurveyInitial());
    } catch (e) {
      emit(SnackbarMessageSurveyState(e.toString()));
    }
  }

  void _onDeleteNotesEvent(
      DeleteNotesEvent event, Emitter<SurveyState> emit) async {
    try {
      final response = await repo.deleteNoteForSurveys(event.noteId);
      if (response) {
        surveyNotesList
            .removeWhere((element) => element.noteId == event.noteId);
        emit(SnackbarMessageSurveyState('Note successfully deleted'));
        emit(SurveyInitial());
      } else {
        emit(SnackbarMessageSurveyState('Failed to delete note'));
      }
    } catch (e) {
      emit(SnackbarMessageSurveyState(e.toString()));
    }
  }

  void _onGetNotesEvent(GetNotesEvent event, Emitter<SurveyState> emit) async {
    try {
      surveyNotesList = await repo.getNoteForSurveys(selectedSurvey!.uuid);
      emit(SurveyInitial());
    } catch (e) {
      emit(SnackbarMessageSurveyState(e.toString()));
    }
  }

  void _onCreateNotesEvent(
      CreateNotesEvent event, Emitter<SurveyState> emit) async {
    try {
      if (event.comment.isEmpty) {
        emit(SnackbarMessageSurveyState('Please add notes text.'));
        return;
      }
      final savedNote =
          await repo.addNoteForSurveys(event.comment, selectedSurvey!.uuid);
      surveyNotesList.add(savedNote);
      emit(SnackbarMessageSurveyState('Note created successfully.'));
    } catch (e) {
      emit(SnackbarMessageSurveyState(e.toString()));
    }
  }

  void _onAnswerUpdatedSurveyEvent(AnswerUpdatedSurveyEvent event, emit) async {
    _fetchOptionAccordingtoCondition(event, emit);
    saveAnswersForSelectedSection();
    _updateQuestionModelWithRule();
    emit(SurveyQuestionsLoadedState());
  }

  Future<void> _uploadImageEvent(UploadImageEvent event, emit) async {
    try {
      final image = await repo.getImageUrlPath(event.path);
      if (!event.isIssue) {
        questionAnswers
            .firstWhereOrNull((element) => element.uuid == event.questionUuid)
            ?.answer = image;
      }
      questionAnswers
          .firstWhereOrNull((element) => element.uuid == event.questionUuid)
          ?.isfromImage = false;
      // _updateQuestionModelWithRule();
      emit(SurveyQuestionsLoadedState());
    } catch (error) {
      emit(SnackbarMessageSurveyState(error.toString()));
    }
  }

  Future<void> _fetchOptionAccordingtoCondition(
      AnswerUpdatedSurveyEvent event, emit) async {
    //  emit(SurveyListLoadingState());
    if (selectedSurvey?.name.trim().toLowerCase() == "on call data info" &&
        event.question.trim().toLowerCase() == "state name") {
      List<String> data = await repo.getDistrictByState(event.answer);
      var lastSelectedQuestions = selectedSurveyFormSections
          .firstWhereOrNull(
              (element) => element.uuid == lastSelectedSectionUuid)
          ?.selectedSectionQuestions;
      if (lastSelectedQuestions == null) return;

      String otion = data.join(",");
      lastSelectedQuestions
          .where((element) =>
              element.question.trim().toLowerCase() == "district name")
          .forEach((element) {
        element.options = otion;
      });
      lastSelectedQuestions
          .where((element) =>
              element.question.trim().toLowerCase() ==
              "name of working area / village")
          .forEach((element) {
        element.options = "";
      });
      lastSelectedQuestions
          .where((element) =>
              element.question.trim().toLowerCase() == "promoter id")
          .forEach((element) {
        element.options = "";
      });
      saveAnswersForSelectedSection();
      _updateQuestionModelWithRule();
    }

    if (selectedSurvey?.name.trim().toLowerCase() == "on call data info" &&
        event.question.trim().toLowerCase() == "district name") {
      List<String> data = await repo.getCityByDistrict(event.answer);
      List<String> dataPomoter = await repo.getPromoterByDistrict(event.answer);
      var lastSelectedQuestions = selectedSurveyFormSections
          .firstWhereOrNull(
              (element) => element.uuid == lastSelectedSectionUuid)
          ?.selectedSectionQuestions;
      if (lastSelectedQuestions == null) return;
      data.add("Others");
      String otion = data.join(",");
      lastSelectedQuestions
          .where((element) =>
              element.question.trim().toLowerCase() ==
              "name of working area / village")
          .forEach((element) {
        element.options = otion;
      });
      String otion2 = dataPomoter.join(",");
      lastSelectedQuestions
          .where((element) =>
              element.question.trim().toLowerCase() == "promoter id")
          .forEach((element) {
        element.options = otion2;
      });
      saveAnswersForSelectedSection();
      _updateQuestionModelWithRule();
    }
    add(ChangeStateEvent());
  }

  Future<Map<String, Object>> _getSubmitRequestBody() async {
    final surveyResponse = selectedSurveyFormSections.map((section) async {
      final questions = section.selectedSectionQuestions
          .where((question) => question.answer?.trim().isNotEmpty ?? false)
          .map((question) async {
        var answer = question.answer;
        if (question.questionInputType == QuestionInputType.image) {
          if (!question.answer!.urlValid()) {
            answer = await repo.getImageUrlPath(question.answer ?? '');
          }
        }
        return {
          "questionName": question.question,
          "questionUuid": question.uuid,
          "questionDataType": question.questionInputType.toSurveyStringName(),
          "answer": answer,
          "mandatory": question.isInputMandatory
        };
      });
      return {
        "sectionName": section.name,
        "sectionUuid": section.uuid,
        "questions": await Future.wait(questions),
      };
    });
    String clientfileUrl = "";
    
    if (clientfile != null) {
      clientfileUrl =
          await repo.getImageUrlPath(clientfile!.path); //, "clientfileUrl");
    }
    Position userLocation =
        await ContinuousLocationService.instance.resolveForSecureAction();
    String address = "Fetching address...";
    address =  await   repo.getAddressFromLatLng(userLocation.latitude,userLocation.longitude);
    return {
      "imageUrl": formEditting
          ? selectedSurveyUserResponse?.image ?? ""
          : clientfileUrl,
      "clientName": clientNameForQuestionnaire,
      "surveyUuid": selectedSurvey!.uuid,
      "surveyResponse": await Future.wait(surveyResponse),
      "surveyGeoTag": {
        "latitude": "${userLocation.latitude}",
        "longitude": "${userLocation.longitude}",
        "inLocation": address
      },
    };
  }

  bool _checkValidations(Emitter<SurveyState> emit) {
    for (final q in _allQuestions()) {
      if (q.answer?.trim().isEmpty ?? true) {
        continue;
      } else if (q.inputTypeValidation == 'pan_number') {
        final bool mobileValid =
            RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(q.answer ?? '');
        if ((q.answer ?? '').isEmpty) {
          emit(SnackbarMessageSurveyState(
              "Please enter PAN number for ${q.question}"));
        } else if (!mobileValid) {
          emit(SnackbarMessageSurveyState(
              "Please enter valid PAN for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'aadhar_number') {
        final bool adharValid =
            RegExp(r'^[2-9]{1}[0-9]{11}$').hasMatch(q.answer ?? '');
        if ((q.answer ?? '').isEmpty) {
          emit(SnackbarMessageSurveyState(
              "Please enter Aadhar number for ${q.question}"));
        } else if (!adharValid) {
          emit(SnackbarMessageSurveyState(
              "Please enter valid Aadhar for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'mobile_number') {
        final bool mobileValid =
            RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(q.answer ?? '');
        if ((q.answer ?? '').isEmpty) {
          emit(SnackbarMessageSurveyState(
              "Please enter mobile number for ${q.question}"));
        } else if (!mobileValid) {
          emit(SnackbarMessageSurveyState(
              "Please enter valid contact for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'email') {
        final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(q.answer ?? '');
        if (!emailValid) {
          emit(SnackbarMessageSurveyState(
              "Please enter valid email for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'url') {
        const regex =
            r"^(?:http|https):\/\/[\w\-_]+(?:\.[\w\-_]+)+[\w\-.,@?^=%&:/~\\+#]*$";
        final bool validURl = RegExp(regex).hasMatch(q.answer ?? '');
        if (!validURl) {
          emit(SnackbarMessageSurveyState(
              "Please enter valid URL for ${q.question}"));
          return false;
        }
      }
    }
    return true;
  }

  void saveAnswersForSelectedSection() {
    var lastSelectedQuestions = selectedSurveyFormSections
        .firstWhereOrNull((element) => element.uuid == lastSelectedSectionUuid)
        ?.selectedSectionQuestions;

    for (final q in questionAnswers) {
      lastSelectedQuestions
          ?.firstWhereOrNull((element) => element.uuid == q.uuid)
          ?.answer = q.answer;
    }
  }

  List<SurveyFormQuestionModel> _allQuestions() {
    return selectedSurveyFormSections
        .map((e) => e.selectedSectionQuestions)
        .expand((element) => element)
        .toList();
  }

  List<SurveyFormQuestionModel> _totalNotAnsweredQuestions() {
    return _getQuestionsAccordingToGivenAnswers(_allQuestions())
        .where((element) =>
            element.isInputMandatory &&
            (element.answer?.trim().isEmpty ?? true))
        .toList();
  }

  void _updateQuestionModelWithRule() {
    var lastSelectedQuestions = selectedSurveyFormSections
        .firstWhereOrNull((element) => element.uuid == lastSelectedSectionUuid)
        ?.selectedSectionQuestions;
    if (lastSelectedQuestions == null) return;

    questionAnswers =
        _getQuestionsAccordingToGivenAnswers(lastSelectedQuestions)
            .map((e) => e.toViewQuestionModel())
            .toList();
    questionAnswers.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
  }

  List<SurveyFormQuestionModel> _getQuestionsAccordingToGivenAnswers(
      List<SurveyFormQuestionModel> lastSelectedQuestions) {
    List<SurveyFormQuestionModel> newquestionsList = [];
    for (var question in lastSelectedQuestions) {
      if (question.rules.isEmpty) {
        newquestionsList.add(question);
      } else {
        final rule = question.rules.first;
        final compareQuestion = newquestionsList
            .firstWhereOrNull((q) => q.uuid == rule.questionUuid);
        List<String> compareAnser =
            (compareQuestion?.answer?.split(',') ?? <String>[]);
        for (var element in compareAnser) {
          element.trim();
        }
        if (compareAnser.contains(rule.answer)) {
          newquestionsList.add(question);
        } else if (compareQuestion?.answer?.trim().toLowerCase() ==
            rule.answer.trim().toLowerCase()) {
          newquestionsList.add(question);
        }
      }
    }
    return newquestionsList;
  }
}

extension Compare on String {
  bool isSameWord(String? b) {
    return trim().toLowerCase() == b?.trim().toLowerCase();
  }
}

extension ListExtention on List<FilledSurveyUserResponse> {
  List<FilledSurveyQuestionResponse> getfilterQuestion() {
    List<FilledSurveyQuestionResponse> questionResponse = [];
    for (var element in this) {
      questionResponse.addAll(element.questionResponse);
    }
    return questionResponse.unique(((element) => element.questionUuid));
  }
}
