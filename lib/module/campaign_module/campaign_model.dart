import 'dart:convert';

import 'package:i_densfa/module/assessment_module/assessment_model.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';

class UserCampaignsModel {
  UserCampaignsModel({
    required this.message,
    required this.status,
    required this.dataList,
  });

  String message;
  String status;
  List<CampaignDetailModel>? dataList;

  factory UserCampaignsModel.fromRawJson(String str) =>
      UserCampaignsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserCampaignsModel.fromJson(Map<String, dynamic> json) =>
      UserCampaignsModel(
        message: json["message"],
        status: json["status"],
        dataList: json["dataList"] == null
            ? []
            : List<CampaignDetailModel>.from(
                json["dataList"].map((x) => CampaignDetailModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "dataList": dataList == null
            ? null
            : List<dynamic>.from(dataList!.map((x) => x.toJson())),
      };
}

class CampaignDetailModel {
  CampaignDetailModel({
    required this.campaignId,
    required this.name,
    required this.description,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.imageName,
    required this.companyId,
    required this.campaignData,
  });

  int campaignId;
  String name;
  String description;
  DateTime startDate;
  String startTime;
  DateTime endDate;
  String endTime;
  String imageName;
  int companyId;
  CampaignDataModel? campaignData;

  factory CampaignDetailModel.fromRawJson(String str) =>
      CampaignDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CampaignDetailModel.fromJson(Map<String, dynamic> json) {
    return CampaignDetailModel(
        campaignId: json["campaignId"],
        name: json["name"],
        description: json["description"],
        startDate: DateTime.parse(json["startDate"]),
        startTime: json["startTime"],
        endDate: DateTime.parse(json["endDate"]),
        endTime: json["endTime"],
        imageName: json["imageName"],
        campaignData: json["campaignData"] == null
            ? null
            : CampaignDataModel.fromJson(json["campaignData"]),
        companyId: json["companyId"]);
  }

  Map<String, dynamic> toJson() => {
        "CampaignResponse": {
          "campaignId": campaignId,
          "name": name,
          "description": description,
          "startDate": startDate,
          "startTime": startTime,
          "endDate": endDate,
          "endTime": endTime,
          "imageName": imageName,
          "companyId": companyId,
        }
      };
}

class CampaignQuestionsModel {
  CampaignQuestionsModel({
    required this.message,
    required this.status,
    required this.data,
  });

  String message;
  String status;
  ResponseData? data;

  factory CampaignQuestionsModel.fromRawJson(String str) =>
      CampaignQuestionsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CampaignQuestionsModel.fromJson(Map<String, dynamic> json) =>
      CampaignQuestionsModel(
        message: json["message"],
        status: json["status"],
        data: json["data"] == null ? null : ResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "data": data?.toJson(),
      };
}

class ResponseData {
  ResponseData({
    required this.questionData,
  });

  List<CampQuestionModel> questionData;

  factory ResponseData.fromRawJson(String str) =>
      ResponseData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
        questionData: List<CampQuestionModel>.from(
            json["questionData"].map((x) => CampQuestionModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "questionData": List<dynamic>.from(questionData.map((x) => x.toJson())),
      };
}

class CampQuestionModel {
  CampQuestionModel({
    required this.id,
    required this.campaignId,
    required this.questionText,
    required this.options,
    required this.questionType,
    required this.sequence,
  });

  int id;
  int campaignId;
  String questionText;
  List<String> options;
  QuestionInputType questionType;
  int sequence;

  factory CampQuestionModel.fromRawJson(String str) =>
      CampQuestionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CampQuestionModel.fromJson(Map<String, dynamic> json) =>
      CampQuestionModel(
        id: json["id"],
        campaignId: json["campaignId"],
        questionText: json["questionText"],
        options: List<String>.from(json["options"].map((x) => x)),
        questionType:
            QuestionInputType.singleLineText.fromString(json["questionType"]),
        sequence: json["sequence"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "campaignId": campaignId,
        "questionText": questionText,
        "options": List<dynamic>.from(options.map((x) => x)),
        "questionType": questionType.toStringName(),
        "sequence": sequence,
      };

  QuestionModel toViewQuestionModel() => QuestionModel(
      isRequired: true,
      options: options,
      question: questionText,
      questionType: questionType,
      placholder: questionText,
      campQuestionModel: this);
}

class CampaignDataModel {
  CampaignDataModel({
    required this.targetedSubDealers,
    required this.includedSubDealers,
    required this.subDetalers,
    required this.totalResponse,
  });

  int subDetalers;
  int targetedSubDealers;
  int includedSubDealers;
  int totalResponse;

  factory CampaignDataModel.fromRawJson(String str) =>
      CampaignDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CampaignDataModel.fromJson(Map<String, dynamic> json) =>
      CampaignDataModel(
          includedSubDealers: json["includedSubDealers"],
          targetedSubDealers: json["targetedSubDealers"],
          subDetalers: json["totalSubDealers"],
          totalResponse: json["totalResponse"] ?? 0);

  Map<String, dynamic> toJson() => {
        "totalResponse": totalResponse,
        "includedSubDealers": includedSubDealers,
        "targetedSubDealers": targetedSubDealers,
        "totalSubDealers": subDetalers
      };
}
