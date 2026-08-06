import 'dart:convert';

import 'survey_form_question_model.dart';

class SurveyFormSectionModel {
  final String uuid;
  final String name;
  final String description;
  final int priorityOrder;
  List<SurveyFormQuestionModel> selectedSectionQuestions = [];

  SurveyFormSectionModel({
    required this.uuid,
    required this.name,
    required this.description,
    required this.priorityOrder,
  });

  factory SurveyFormSectionModel.fromRawJson(String str) =>
      SurveyFormSectionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SurveyFormSectionModel.fromJson(Map<String, dynamic> json) =>
      SurveyFormSectionModel(
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
