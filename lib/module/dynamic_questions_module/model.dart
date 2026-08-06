import 'package:flutter/material.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';

class QuestionModel {
  final String uuid;
  final String question;
  String? answer;
  final QuestionInputType questionType;
  final String? placholder;
  List<String> options;
  final TextInputType? keyboardPref;
  final ImageFrom? imageFrom;
  final bool isRequired;
  int questionOrder;
  bool isEditable =true;
  bool isIssue;
  String? issuesImage;
  String? issuesRemark;
  String? correctAnswer;
  String? dateTimeformat;
  TextEditingController textEditingController = TextEditingController();
  TextEditingController issuesTextEditingController = TextEditingController();
  CampaignQuestionModel? campQuestionModel;
  bool isfromImage = false;

  QuestionModel(
      {required this.isIssue,
      this.correctAnswer,
      this.issuesImage,
      this.issuesRemark,
      required this.uuid,
      required this.question,
      required this.questionType,
      this.placholder,
      this.keyboardPref,
      this.imageFrom,
      this.dateTimeformat,
      this.answer,
      required this.options,
      required this.isRequired,
      this.campQuestionModel,
      required this.isEditable,
      required this.questionOrder});
}

enum QuestionInputType {
  multiSelectDropdown,
  dropdown,
  amount,
  number,
  radio,
  image,
  boolean,
  singleLineText,
  multiLineText,
  ddMMyy,
  time,
  multiAnswers,
  rating
}

enum ImageFrom { camera, gallery }

extension Helper on QuestionInputType {
  QuestionInputType fromString(String type) {
    switch (type) {
      case "MULTI_SELECT_CHECKBOX":
        return QuestionInputType.multiAnswers;
      case "MULTI_SELECT_DROPDOWN":
       return QuestionInputType.multiSelectDropdown;
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
      case "RATE":
        return QuestionInputType.rating;
      case "DATE":
        return QuestionInputType.ddMMyy;
       case "TIME":
        return QuestionInputType.time;
      default:
        return QuestionInputType.singleLineText;
    }
  }

  String toSurveyStringName() {
    switch (this) {
      case QuestionInputType.multiSelectDropdown:
      return"MULTI_SELECT_DROPDOWN";
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
        return 'DATE';
      case QuestionInputType.time:
        return 'TIME';
      case QuestionInputType.rating:
        return "RATE";
      case QuestionInputType.multiAnswers:
        return 'MULTI_SELECT_CHECKBOX';
    }
  }

  String toCampaignStringName() {
    switch (this) {
      case QuestionInputType.multiSelectDropdown:
      return"MULTI_SELECT_DROPDOWN";
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
        return 'DATE';
        case QuestionInputType.time:
        return 'TIME';
      case QuestionInputType.rating:
        return "RATE";
      case QuestionInputType.multiAnswers:
        return 'MULTI_SELECT_CHECKBOX';
    }
  }

  String toAssessmentStringName() {
    switch (this) {
      case QuestionInputType.multiSelectDropdown:
      return"MULTI_SELECT_DROPDOWN";
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
        return "DATE";
        case QuestionInputType.time:
        return 'TIME';
      case QuestionInputType.amount:
        return "";
      case QuestionInputType.rating:
        return "RATE";
    }
  }
}
