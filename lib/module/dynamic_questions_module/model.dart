import 'package:flutter/material.dart';
import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';

class QuestionModel {
  final String question;
  String? answer;
  final QuestionInputType questionType;
  final String? placholder;
  List<String> options;
  final TextInputType? keyboardPref;
  final bool isRequired;
  AssessQuestionModel? assessmentQuestionDetails;
  CampQuestionModel? campQuestionModel;

  QuestionModel(
      {required this.question,
      required this.questionType,
      this.placholder,
      this.keyboardPref,
      required this.options,
      required this.isRequired,
      this.assessmentQuestionDetails,
      this.campQuestionModel});

  Map<String, dynamic> toAssessmentRequest() {
    return {
      "options": options,
      "questionText": question,
      "questionType": questionType.toStringName(),
      "userAnswer": answer ?? "",
      "assessmentId": assessmentQuestionDetails?.assessmentId,
      "correctAnswer": assessmentQuestionDetails?.correctAnswer,
      "id": assessmentQuestionDetails?.id,
      "sequence": assessmentQuestionDetails?.sequence,
    };
  }

  Map<String, dynamic> toCampaignRequest() {
    return {
      "options": options,
      "questionText": question,
      "questionType": questionType.toStringName(),
      "userAnswer": answer ?? "",
      "campaignId": campQuestionModel?.campaignId,
      "id": campQuestionModel?.id,
      "sequence": campQuestionModel?.sequence,
    };
  }
}

//New Model need to update
/**
 import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'dart:convert';

class QuestionModel {
  final String question;
  String options;
  final String description;
  final List<Rule> rules;
  final bool isInputMandatory;
  final QuestionInputType questionInputType;
  final String inputTypeValidation;
  String? answer;
  String? placholder;
  QuestionModel({
    required this.question,
    required this.options,
    required this.description,
    required this.rules,
    required this.isInputMandatory,
    required this.questionInputType,
    required this.inputTypeValidation,
  });

  factory QuestionModel.fromRawJson(String str) =>
      QuestionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        question: json["question"],
        options: json["options"],
        description: json["description"],
        rules: List<Rule>.from(json["rules"].map((x) => Rule.fromJson(x))),
        isInputMandatory: json["isInputMandatory"],
        questionInputType:
            QuestionInputType.amount.fromString(json["questionInputType"]),
        inputTypeValidation: json["inputTypeValidation"],
      );

  Map<String, dynamic> toJson() => {
        "question": question,
        "options": options,
        "description": description,
        "rules": List<dynamic>.from(rules.map((x) => x.toJson())),
        "isInputMandatory": isInputMandatory,
        "questionInputType": questionInputType.toStringName(),
        "inputTypeValidation": inputTypeValidation,
      };
}

class Rule {
  final String questionUuid;
  final String question;
  final String answer;

  Rule({
    required this.questionUuid,
    required this.question,
    required this.answer,
  });

  factory Rule.fromRawJson(String str) => Rule.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        questionUuid: json["questionUuid"],
        question: json["question"],
        answer: json["answer"],
      );

  Map<String, dynamic> toJson() => {
        "questionUuid": questionUuid,
        "question": question,
        "answer": answer,
      };
}

 */