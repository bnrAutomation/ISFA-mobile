import 'dart:convert';

import 'question.dart';

class CampaignQuestionSectionModel {
  final String uuid;
  final String name;
  final String description;
  final int priorityOrder;
  List<CampaignQuestionModel> selectedSectionQuestions = [];

  CampaignQuestionSectionModel({
    required this.uuid,
    required this.name,
    required this.description,
    required this.priorityOrder,
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
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "name": name,
        "description": description,
        "priorityOrder": priorityOrder,
      };
}
