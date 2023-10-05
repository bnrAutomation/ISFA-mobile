import 'package:flutter/material.dart';
import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';

class QuestionModel {
  final String question;
  String? answer;
  final QuestionInputType questionType;
  final String? placholder;
  List<String> options;
  final TextInputType? keyboardPref;
  final bool isRequired;
  AssessQuestionModel? assessmentQuestionDetails;
  CampaignQuestionModel? campQuestionModel;

  QuestionModel(
      {required this.question,
      required this.questionType,
      this.placholder,
      this.keyboardPref,
      this.answer,
      required this.options,
      required this.isRequired,
      this.assessmentQuestionDetails,
      this.campQuestionModel});

  Map<String, dynamic> toAssessmentRequest() {
    return {
      "options": options,
      "questionText": question,
      "questionType": questionType.toAssessmentStringName(),
      "userAnswer": answer ?? "",
      "assessmentId": assessmentQuestionDetails?.assessmentId,
      "correctAnswer": assessmentQuestionDetails?.correctAnswer,
      "id": assessmentQuestionDetails?.id,
      "sequence": assessmentQuestionDetails?.sequence,
    };
  }
}

enum QuestionInputType {
  dropdown,
  amount,
  number,
  radio,
  image,
  boolean,
  singleLineText,
  multiLineText,
  ddMMyy,
  multiAnswers
}

extension Helper on QuestionInputType {
  QuestionInputType fromString(String type) {
    switch (type) {
      case "MULTI_SELECT_CHECKBOX":
        return QuestionInputType.multiAnswers;
      case "SINGLE_SELECT_DROPDOWN":
      case "QUESTION_WITH_OPTIONS_DROP_DOWN":
        return QuestionInputType.dropdown;
      case "SINGLE_SELECT_RADIO":
      case "QUESTION_WITH_OPTIONS_CHECK_BOX":
        return QuestionInputType.radio;
      case "BOOLEAN":
        return QuestionInputType.boolean;
      case "QUESTION_WITH_TRUE_FALSE":
        return QuestionInputType.boolean;

      case "NUMBER":
        return QuestionInputType.number;
      case "TEXT":
      case "QUESTION_WITH_CORRECT_ANSWER":
        return QuestionInputType.singleLineText;
      case "IMAGE":
        return QuestionInputType.image;

      default:
        return QuestionInputType.singleLineText;
    }
  }

  String toCampaignStringName() {
    switch (this) {
      case QuestionInputType.dropdown:
        return 'SINGLE_SELECT_DROPDOWN';
      case QuestionInputType.amount:
        return '';
      case QuestionInputType.number:
        return 'NUMBER';
      case QuestionInputType.radio:
        return 'SINGLE_SELECT_RADIO';
      case QuestionInputType.image:
        return 'IMAGE';
      case QuestionInputType.boolean:
        return 'BOOLEAN';
      case QuestionInputType.singleLineText:
        return 'TEXT';
      case QuestionInputType.multiLineText:
        return '';
      case QuestionInputType.ddMMyy:
        return '';
      case QuestionInputType.multiAnswers:
        return 'MULTI_SELECT_CHECKBOX';
    }
  }

  String toAssessmentStringName() {
    switch (this) {
      case QuestionInputType.dropdown:
        return "QUESTION_WITH_OPTIONS_DROP_DOWN";
      case QuestionInputType.number:
        return "QUESTION_WITH_NUMERIC_ANSWER";
      case QuestionInputType.radio:
        return "QUESTION_WITH_OPTIONS_CHECK_BOX";
      case QuestionInputType.boolean:
        return "QUESTION_WITH_TRUE_FALSE";
      case QuestionInputType.singleLineText:
        return "QUESTION_WITH_CORRECT_ANSWER";
      case QuestionInputType.multiAnswers:
        return "";
      case QuestionInputType.image:
        return "IMAGE";
      case QuestionInputType.multiLineText:
        return "";
      case QuestionInputType.ddMMyy:
        return "";
      case QuestionInputType.amount:
        return "";
    }
  }
}
