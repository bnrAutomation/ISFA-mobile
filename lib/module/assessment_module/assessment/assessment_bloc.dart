import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_densfa/module/assessment_module/assessment_repository.dart';
import 'package:i_densfa/module/assessment_module/model/assessment_model.dart';
import 'package:i_densfa/module/assessment_module/model/get_all_questions_model.dart';
import 'package:i_densfa/module/assessment_module/model/get_all_sections_model.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/base_bloc.dart';

part 'assessment_event.dart';
part 'assessment_state.dart';

class AssessmentBloc extends BaseBloc<AssessmentEvent, AssessmentState> {
  AssessmentRepository repo;
  AssessmentListItemModel? selectedAssessment;
  AssessmentLevel? selectedAssessmentLevel;
  List<AssessmentListItemModel> assessmentList = [];
  List<AssessmentLevel> assessmentLevel = [];
  List<GetAllSectionsModel> selectedAssessmentFormSections = [];

  String lastSelectedSectionUuid = '';
  List<QuestionModel> questionAnswers = [];
  AssessmentResponse? assessmentResponse;

  int secondsTook = 0;

  String timeLeft() {
    final int totalMin = selectedAssessmentLevel?.timeLimit ?? 1;
    final int totalSeconds = totalMin * 60;
    final int time = totalSeconds - secondsTook;

    final Duration duration = Duration(seconds: time);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String hours =
        duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : '';
    return "$hours$twoDigitMinutes:$twoDigitSeconds";
  }

  AssessmentBloc(this.repo) : super(AssessmentInitial()) {
    on<AssessmentEvent>((event, emit) {});
    on(_onGetAssessmentEvent);
    on(_onGetLevelEvent);
    on(_onGetLevelSectionEvent);
    on(_onGetQuestionsForSection);
    on(_onAnswerUpdatedAssessmentEvent);
    on(_onSaveAssessmentAnswersEvent);
    on(_uploadImageEvent);
    on<UpdateTimerValueEvent>(
        (event, emit) => emit(TimerUpdateAssessmentState(event.timeLeft)));
    on((StartQuestionCountDownTimerAssessmentEvent event, emit) {
      secondsTook = 0;
      for (var element in questionAnswers) {
        element.answer = null;
      }
      createPeriodicTimer(const Duration(seconds: 1), (timer) {
        secondsTook += 1;
        if ((secondsTook ~/ 60) >= (selectedAssessmentLevel?.timeLimit ?? 1)) {
          timer.cancel();
          safeAdd(SaveAssessmentAnswersEvent(false));
        } else {
          safeAdd(UpdateTimerValueEvent(timeLeft()));
        }
      });
    });
  }

  void _onGetAssessmentEvent(GetAssessmentEvent event, emit) async {
    try {
      assessmentList = [];
      emit(AssessmentListLoadingState());
      assessmentList = await repo.getAssessment();
      emit(AssessmentListLoadedState());
    } catch (e) {
      emit(SnackbarMessageState(e.toString()));
    }
  }

  void _onGetLevelEvent(GetAssessmentLevel event, emit) async {
    selectedAssessment = event.item;
    assessmentLevel = [];
    try {
      emit(AssessmentListLoadingState());
      assessmentLevel = await repo.getAssessmentLevel(event.item.uuid);
      assessmentLevel.sort((a, b) => a.levelOrder.compareTo(b.levelOrder));
      emit(AssessmentListLoadedState());
    } catch (e) {
      emit(SnackbarMessageState(e.toString()));
    }
  }

  void _onGetLevelSectionEvent(GetSectionEvent event, emit) async {
    try {
      selectedAssessmentLevel = event.item;
      selectedAssessmentFormSections = [];
      selectedAssessmentFormSections = (await repo.getAllSections(
          event.item.uuid, selectedAssessment?.uuid ?? ""));
      selectedAssessmentFormSections
          .sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
      if (selectedAssessmentFormSections.isNotEmpty) {
        add(GetQuestionsForSection(selectedAssessmentFormSections[0].uuid));
      }
      emit(AssessmentListLoadedState());
    } catch (e) {
      emit(SnackbarMessageState(e.toString()));
    }
  }

  void _onGetQuestionsForSection(GetQuestionsForSection event, emit) async {
    saveAnswersForSelectedSection();
    lastSelectedSectionUuid = event.sectionUuId;
    var questions = selectedAssessmentFormSections
        .firstWhere((element) => element.uuid == event.sectionUuId)
        .selectedSectionQuestions;
    questionAnswers.clear();
    emit(AssessmentQuestionsLoadedState());
    if (questions.isEmpty) {
      emit(AssessmentListLoadingState());
      questions = await repo.getAllQuestions(selectedAssessment?.uuid ?? "",
          selectedAssessmentLevel?.uuid ?? "", event.sectionUuId);
      questions.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
      // merging updated question and answers with sections
      selectedAssessmentFormSections
          .firstWhere((element) => element.uuid == event.sectionUuId)
          .selectedSectionQuestions = questions;
    }
    _updateQuestionModelWithRule();
    emit(AssessmentQuestionsLoadedState());
  }

  void saveAnswersForSelectedSection() {
    var lastSelectedQuestions = selectedAssessmentFormSections
        .firstWhereOrNull((element) => element.uuid == lastSelectedSectionUuid)
        ?.selectedSectionQuestions;
    for (final q in questionAnswers) {
      lastSelectedQuestions
          ?.firstWhereOrNull((element) => element.uuid == q.uuid)
          ?.answer = q.answer;
    }
  }

  void _updateQuestionModelWithRule() {
    var lastSelectedQuestions = selectedAssessmentFormSections
        .firstWhereOrNull((element) => element.uuid == lastSelectedSectionUuid)
        ?.selectedSectionQuestions;
    if (lastSelectedQuestions == null) return;

    questionAnswers =
        _getQuestionsAccordingToGivenAnswers(lastSelectedQuestions)
            .map((e) => e.toViewQuestionModel())
            .toList();
    questionAnswers.sort((a, b) => a.questionOrder.compareTo(b.questionOrder));
  }

  List<GetQuestionsModel> _getQuestionsAccordingToGivenAnswers(
      List<GetQuestionsModel> lastSelectedQuestions) {
    List<GetQuestionsModel> newquestionsList = [];
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
        if (compareAnswer.contains(rule.answer)) {
          newquestionsList.add(question);
        } else if (compareQuestion?.answer?.trim().toLowerCase() ==
            rule.answer.trim().toLowerCase()) {
          newquestionsList.add(question);
        }
      }
    }

    // List<GetQuestionsModel> newquestionsList = [];
    // for (var question in lastSelectedQuestions) {
    //   if (question.rules.isEmpty) {
    //     newquestionsList.add(question);
    //   } else {
    //     final rule = question.rules.first;
    //     final compareQuestion = newquestionsList
    //         .firstWhereOrNull((q) => q.uuid == rule.questionUuid);
    //     if ((compareQuestion?.answer?.split(',') ?? []).contains(rule.answer)) {
    //       newquestionsList.add(question);
    //     } else if (compareQuestion?.answer?.toLowerCase() ==
    //         rule.answer.toLowerCase()) {
    //       newquestionsList.add(question);
    //     }
    //   }
    // }
    return newquestionsList;
  }

  void _onAnswerUpdatedAssessmentEvent(
      AnswerUpdatedAssessmentEvent event, emit) async {
    saveAnswersForSelectedSection();
    _updateQuestionModelWithRule();
    emit(AssessmentQuestionsLoadedState());
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
      //_updateQuestionModelWithRule();
      emit(AssessmentQuestionsLoadedState());
    } catch (error) {
      emit(SnackbarMessageState(error.toString()));
    }
  }

  void _onSaveAssessmentAnswersEvent(
      SaveAssessmentAnswersEvent event, emit) async {
    saveAnswersForSelectedSection();

    final unAnsweredSection = event.checkLeftAnswer
        ? selectedAssessmentFormSections.firstWhereOrNull(
            (element) => element.selectedSectionQuestions.isEmpty)
        : null;

    if (unAnsweredSection != null) {
      emit(SnackbarMessageState(
          "Please answer for Section: ${unAnsweredSection.name}"));
      return;
    }

    final notAnsweredQuestions =
        event.checkLeftAnswer ? _totalNotAnsweredQuestions() : [];

    if (notAnsweredQuestions.isNotEmpty) {
      emit(SnackbarMessageState(
          "Please answer for ${notAnsweredQuestions.first.question}"));
      return;
    }
    if (!_checkValidations(emit)) return;
    // Timer is automatically managed by BaseBloc
    emit(SavingAnswersLoadingState());
    try {
      final reqBody = await _getSubmitRequestBody();
      assessmentResponse = await repo.saveAssessmentAnswers(reqBody);
      debugPrint(jsonEncode(assessmentResponse));
      emit(SnackbarMessageState("Saved Successfully"));
      emit(ScoreCalculatedAssessmentState());
    } catch (error) {
      emit(SnackbarMessageState(error.toString()));
    }
  }

  Future<Map<String, Object>> _getSubmitRequestBody() async {
    final assessmentResponse =
        selectedAssessmentFormSections.map((section) async {
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
          "answer": answer
        };
      });
      return {
        "sectionName": section.name,
        "sectionUuid": section.uuid,
        "questions": await Future.wait(questions),
      };
    });
    final levelResponse = {
      "levelName": selectedAssessmentLevel?.name ?? "",
      "levelUuid": selectedAssessmentLevel?.uuid ?? "",
      "timeSpend": secondsTook,
      "sections": await Future.wait(assessmentResponse)
    };
    return {
      "assessmentUuid": selectedAssessment?.uuid ?? "",
      "assessmentResponse": levelResponse
    };
  }

  bool _checkValidations(Emitter<AssessmentState> emit) {
    for (final q in _allQuestions()) {
      if (q.answer?.trim().isEmpty ?? true) {
        continue;
      } else if (q.inputTypeValidation == 'email') {
        final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(q.answer ?? '');
        if (!emailValid) {
          emit(SnackbarMessageState(
              "Please enter valid email for ${q.question}"));
          return false;
        }
      } else if (q.inputTypeValidation == 'url') {
        const regex =
            r"^(?:http|https):\/\/[\w\-_]+(?:\.[\w\-_]+)+[\w\-.,@?^=%&:/~\\+#]*$";
        final bool validURl = RegExp(regex).hasMatch(q.answer ?? '');
        if (!validURl) {
          emit(
              SnackbarMessageState("Please enter valid URL for ${q.question}"));
          return false;
        }
      }
    }
    return true;
  }

  List<GetQuestionsModel> _totalNotAnsweredQuestions() {
    return _getQuestionsAccordingToGivenAnswers(_allQuestions())
        .where((element) =>
            element.isInputMandatory &&
            (element.answer?.trim().isEmpty ?? true))
        .toList();
  }

  List<GetQuestionsModel> _allQuestions() {
    return selectedAssessmentFormSections
        .map((e) => e.selectedSectionQuestions)
        .expand((element) => element)
        .toList();
  }
}
