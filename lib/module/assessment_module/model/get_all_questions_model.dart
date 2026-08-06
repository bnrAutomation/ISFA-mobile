import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';

List<GetQuestionsModel> getQuestionsModelFromJson(String str) =>
    List<GetQuestionsModel>.from(
        json.decode(str).map((x) => GetQuestionsModel.fromJson(x)));

String getQuestionsModelToJson(List<GetQuestionsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetQuestionsModel {
  String question;
  QuestionInputType questionInputType;
  String options;
  String description;
  int? marks;
  String? answer;
  String inputTypeValidation;
  bool isInputMandatory;
  String uuid;
  int questionOrder;
  List<String>? optionsList;
  List<Rule> rules = [];

  GetQuestionsModel(
      {required this.question,
      required this.questionInputType,
      required this.options,
      required this.description,
      this.marks,
      this.answer,
      required this.isInputMandatory,
      required this.uuid,
      this.optionsList,
      required this.rules,
      required this.questionOrder,
      required this.inputTypeValidation});

  factory GetQuestionsModel.fromJson(Map<String, dynamic> data) =>
      GetQuestionsModel(
          question: data["question"] ?? "",
          marks: data['marks'] ?? 0,
          answer: "", //data['answer'],
          rules: data["rules"] == null
              ? []
              : List<Rule>.from(data["rules"].map((x) => Rule.fromJson(x))),
          questionInputType:
              QuestionInputType.amount.fromString(data["questionInputType"]),
          options: data["options"] ?? "",
          questionOrder: data["questionOrder"] ?? 0,
          description: data["description"] ?? "",
          inputTypeValidation: data["inputTypeValidation"] ?? "",
          isInputMandatory: data["isInputMandatory"],
          uuid: data["uuid"],
          optionsList: data["options"].toString().isEmpty
              ? []
              : (data["options"].toString().isNotEmpty &&
                      !data["options"].toString().contains(','))
                  ? [data["options"]]
                  : data["options"].toString().split(','));

  Map<String, dynamic> toJson() => {
        "question": question,
        "questionOrder": questionOrder,
        "questionInputType": questionInputType,
        "options": options,
        "rules": List<dynamic>.from(rules.map((x) => x.toJson())),
        "description": description,
        "isInputMandatory": isInputMandatory,
        "inputTypeValidation": inputTypeValidation,
        "uuid": uuid,
        "marks": marks,
        "answer": answer
      };

  QuestionModel toViewQuestionModel() => QuestionModel(
      isIssue: false,
      isRequired: isInputMandatory,
      options: options.split(','),
      question: question,
      questionType: questionInputType,
      placholder: description,
      answer: answer,
      keyboardPref: keyboardType,
      questionOrder: questionOrder,
      isEditable: true,
      uuid: uuid);
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
  String? questionUuid;
  String? question;
  dynamic answer;

  Rule({
    this.questionUuid,
    this.question,
    this.answer,
  });

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
