import 'package:flutter/widgets.dart';
import 'dart:convert';

import 'package:i_densfa/module/dynamic_questions_module/model.dart';

class SurveyFormQuestionModel {
  final String uuid;
  final String question;
  String options;
  final String description;
  final List<Rule> rules;
  final bool isInputMandatory;
  final QuestionInputType questionInputType;
  final String inputTypeValidation;
  String? answer;
  int questionOrder;
  String? placholder;

  SurveyFormQuestionModel(
      {required this.uuid,
      required this.question,
      required this.options,
      required this.description,
      required this.rules,
      required this.isInputMandatory,
      required this.questionInputType,
      required this.inputTypeValidation,
      required this.questionOrder});

  factory SurveyFormQuestionModel.fromRawJson(String str) =>
      SurveyFormQuestionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SurveyFormQuestionModel.fromJson(Map<String, dynamic> json) =>
      SurveyFormQuestionModel(
          uuid: json["uuid"],
          question: json["question"],
          options: json["options"],
          description: json["description"],
          rules: json["rules"] is List
              ? List<Rule>.from(json["rules"].map((x) => Rule.fromJson(x)))
              : [],
          isInputMandatory: json["isInputMandatory"],
          questionInputType:
              QuestionInputType.amount.fromString(json["questionInputType"]),
          inputTypeValidation: json["inputTypeValidation"] ?? '',
          questionOrder: json["questionOrder"] ?? 0);

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "question": question,
        "options": options,
        "description": description,
        "rules": rules.map((x) => x.toJson()).toList(),
        "isInputMandatory": isInputMandatory,
        "questionInputType": questionInputType.toSurveyStringName(),
        "inputTypeValidation": inputTypeValidation,
        "questionOrder": questionOrder
      };

  QuestionModel toViewQuestionModel() => QuestionModel(
      isIssue: false,
      uuid: uuid,
      isRequired: isInputMandatory,
      options: options.split(','),
      question: question,
      questionType: questionInputType,
      placholder: description,
      answer: answer,
      questionOrder: questionOrder,
      keyboardPref: keyboardType,
      isEditable: true);

  TextInputType? get keyboardType {
    switch (inputTypeValidation.toLowerCase()) {
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      default:
        return null;
    }
  }
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
