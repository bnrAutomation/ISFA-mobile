import 'package:flutter/widgets.dart';
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
  int questionOrder;
  bool isEditable = true;
  bool isIssue;
  String? issuesImage;
  String? issuesRemark;
  String? correctAnswer;
  CampaignQuestionModel(
      {required this.uuid,
      required this.question,
      required this.options,
      required this.description,
      required this.rules,
      required this.isInputMandatory,
      required this.questionInputType,
      required this.inputTypeValidation,
      this.answer,
      this.isEditable = true,
      this.issuesImage,
      this.issuesRemark,
      this.correctAnswer,
      required this.isIssue,
      required this.questionOrder});

  factory CampaignQuestionModel.fromRawJson(String str) =>
      CampaignQuestionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CampaignQuestionModel.fromJson(Map<String, dynamic> json) =>
      CampaignQuestionModel(
          uuid: json["uuid"],
          question: json["question"],
          options: json["options"],
          description: json["description"],
          correctAnswer: json['correctAnswer'],
          rules: json["rules"] is List
              ? List<Rule>.from(json["rules"].map((x) => Rule.fromJson(x)))
              : [],
          isInputMandatory: json["isInputMandatory"],
          questionInputType:
              QuestionInputType.amount.fromString(json["questionInputType"]),
          inputTypeValidation: json["inputTypeValidation"] ?? '',
          answer: json["answer"],
          isEditable: json["isEditable"] ?? true,
          isIssue: json['issue'] ?? false,
          issuesImage: json["issuesImage"],
          issuesRemark: json["issuesRemark"],
          questionOrder: json["questionOrder"] ?? 0);

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "question": question,
        "options": options,
        "description": description,
        "rules": rules.map((x) => x.toJson()).toList(),
        "isInputMandatory": isInputMandatory,
        "questionInputType": questionInputType.toCampaignStringName(),
        "inputTypeValidation": inputTypeValidation,
        "answer": answer,
        "questionOrder": questionOrder,
        "isEditable": isEditable,
        "issue": isIssue,
        "issuesImage": issuesImage,
        "issuesRemark": issuesRemark,
        "correctAnswer": correctAnswer
      };

  QuestionModel toViewQuestionModel() => QuestionModel(
      isIssue: isIssue,
      correctAnswer: correctAnswer,
      issuesImage: issuesImage,
      issuesRemark: issuesRemark,
      uuid: uuid,
      isRequired: isInputMandatory,
      options: options.split(','),
      question: question,
      questionType: questionInputType,
      placholder: description,
      answer: answer,
      questionOrder: questionOrder,
      campQuestionModel: this,
      isEditable: isEditable,
      dateTimeformat: inputTypeValidation,
      imageFrom: getInputValidation(inputTypeValidation),
      keyboardPref: getkeybord(inputTypeValidation));
  getkeybord(String? inputTypeValidation) {
    switch (inputTypeValidation) {
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.emailAddress;
      case 'aadhar_number':
        return TextInputType.number;
      case 'mobile_number':
        return TextInputType.number;
      case 'pan_number':
        return TextInputType.text;
    }
    return null;
  }

  getInputValidation(String? inputTypeValidation) {
    if (inputTypeValidation == "gallery") {
      return ImageFrom.gallery;
    }
    return ImageFrom.camera;
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

class RecruiterModel {
  String counterName;
  String counterPerson;
  String contactNumber;
  String address;
  String image;
  String geoTag;
  String gcinCode;
  String mappedTo;
  int id;
  String outletSegment;
  String pin;
  String district;
  String state;

  RecruiterModel(
      {required this.counterName,
      required this.counterPerson,
      required this.contactNumber,
      required this.address,
      required this.image,
      required this.geoTag,
      required this.mappedTo,
      required this.gcinCode,
      required this.id,
      required this.pin,
      required this.district,
      required this.state,
      required this.outletSegment});

  factory RecruiterModel.fromRawJson(String str) =>
      RecruiterModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecruiterModel.fromJson(Map<String, dynamic> json) => RecruiterModel(
        counterName: json["counterName"] ?? "",
        counterPerson: json["counterPerson"] ?? "",
        contactNumber: json["contactNumber"] ?? "",
        pin: json['pin'] ?? "",
        district: json['district'] ?? "",
        state: json['state'] ?? "",
        address: json["address"] ?? "",
        image: json["image"] ?? "",
        geoTag: json["geoTag"] ?? "",
        mappedTo: json["mappedTo"] ?? "",
        id: json["id"],
        gcinCode: json['gcinCode'] ?? "",
        outletSegment: json['outletSegment'] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "counterName": counterName,
        "counterPerson": counterPerson,
        "contactNumber": contactNumber,
        "address": address,
        "image": image,
        "geoTag": geoTag,
        "mappedTo": mappedTo,
        'gcinCode': gcinCode,
        'outletSegment': outletSegment,
        "pin": pin,
        "district": district,
        "state": state,
      };
}

class MechanicModel {
  String mechanicName;
  String mechanicNumber;
  String address;
  String image;
  String mappedTo;
  int id;
  String pin;
  String district;
  String state;
  String outletName;
  String outletImage;
  String outletSegment;
  bool isActivated;
  bool isEnrolled;

  MechanicModel(
      {required this.mechanicName,
      required this.mechanicNumber,
      required this.address,
      required this.image,
      required this.mappedTo,
      required this.id,
      required this.pin,
      required this.district,
      required this.state,
      required this.outletName,
      required this.outletImage,
      required this.isActivated,
      required this.isEnrolled,
      required this.outletSegment});

  factory MechanicModel.fromRawJson(String str) =>
      MechanicModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MechanicModel.fromJson(Map<String, dynamic> json) => MechanicModel(
      isEnrolled: json["isEnrolled"] ?? false,
      isActivated: json["isActivated"] ?? false,
      mechanicName: json["mechanicName"] ?? "",
      mechanicNumber: json["mechanicNumber"] ?? "",
      address: json["address"] ?? "",
      image: json["image"] ?? "",
      mappedTo: json["mappedTo"] ?? "",
      id: json["id"],
      pin: json['pin'] ?? "",
      district: json['district'] ?? "",
      state: json['state'] ?? "",
      outletName: json['outletName'] ?? "",
      outletImage: json['outletImage'] ?? "",
      outletSegment: json['outletSegment'] ?? "");

  Map<String, dynamic> toJson() => {
        "mechanicName": mechanicName,
        "mechanicNumber": mechanicNumber,
        "address": address,
        "image": image,
        "mappedTo": mappedTo,
        "pin": pin,
        "district": district,
        "state": state,
        "outletName": outletName,
        "outletImage": outletImage,
        "isActivated": isActivated,
        "isEnrolled": isEnrolled
      };
}
