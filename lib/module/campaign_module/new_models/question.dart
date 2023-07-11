import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'dart:convert';

import 'package:i_densfa/module/dynamic_questions_module/model.dart';

class CampaignQuestionModel {
  final String uuid;
  final String question;
  String options;
  final String description;
  final List<Rule> rules;
  final bool isInputMandatory;
  final QuestionInputType questionInputType;
  final String inputTypeValidation;
  String? answer;
  String? placholder;
  CampaignQuestionModel({
    required this.uuid,
    required this.question,
    required this.options,
    required this.description,
    required this.rules,
    required this.isInputMandatory,
    required this.questionInputType,
    required this.inputTypeValidation,
  });

  factory CampaignQuestionModel.fromRawJson(String str) =>
      CampaignQuestionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CampaignQuestionModel.fromJson(Map<String, dynamic> json) =>
      CampaignQuestionModel(
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
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "question": question,
        "options": options,
        "description": description,
        "rules": rules.map((x) => x.toJson()).toList(),
        "isInputMandatory": isInputMandatory,
        "questionInputType": questionInputType.toStringName(),
        "inputTypeValidation": inputTypeValidation,
      };

  QuestionModel toViewQuestionModel() => QuestionModel(
      isRequired: isInputMandatory,
      options: options.split(','),
      question: question,
      questionType: questionInputType,
      placholder: description,
      answer: answer,
      campQuestionModel: this);
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
