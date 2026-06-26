import 'dart:convert';

import 'question.dart';

class SectionRule {
  final String questionUuid;
  final String question;
  final String answer;
  final String sectionUuid;

  SectionRule({
    required this.questionUuid,
    required this.question,
    required this.answer,
    required this.sectionUuid,
  });

  factory SectionRule.fromJson(Map<String, dynamic> json) => SectionRule(
        questionUuid: json["questionUuid"] ?? "",
        question: json["question"] ?? "",
        answer: json["answer"] ?? "",
        sectionUuid: json["sectionUuid"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "questionUuid": questionUuid,
        "question": question,
        "answer": answer,
        "sectionUuid": sectionUuid,
      };
}

class CampaignQuestionSectionModel {
  final String uuid;
  final String name;
  final String description;
  final int priorityOrder;
  final List<SectionRule> rules;
  List<CampaignQuestionModel> selectedSectionQuestions = [];

  CampaignQuestionSectionModel({
    required this.uuid,
    required this.name,
    required this.description,
    required this.priorityOrder,
    this.rules = const [],
  });

  factory CampaignQuestionSectionModel.fromRawJson(String str) =>
      CampaignQuestionSectionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CampaignQuestionSectionModel.fromJson(Map<String, dynamic> json) =>
      CampaignQuestionSectionModel(
        uuid: json["uuid"],
        name: json["name"],
        description: json["description"],
        priorityOrder: json["priorityOrder"],
        rules: json["rules"] is List
            ? List<SectionRule>.from(
                json["rules"].map((x) => SectionRule.fromJson(x)))
            : const [],
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "name": name,
        "description": description,
        "priorityOrder": priorityOrder,
        "rules": rules.map((x) => x.toJson()).toList(),
      };
}
