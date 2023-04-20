import 'dart:convert';

import 'package:i_densfa/module/dynamic_questions_module/model.dart';

class UserAssessmentsModel {
  UserAssessmentsModel({
    required this.message,
    required this.status,
    required this.dataList,
  });

  String message;
  String status;
  List<AssessmentDetailModel>? dataList;

  factory UserAssessmentsModel.fromRawJson(String str) =>
      UserAssessmentsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserAssessmentsModel.fromJson(Map<String, dynamic> json) =>
      UserAssessmentsModel(
        message: json["message"],
        status: json["status"],
        dataList: json["dataList"] == null
            ? []
            : List<AssessmentDetailModel>.from(
                json["dataList"].map((x) => AssessmentDetailModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "dataList": dataList == null
            ? null
            : List<dynamic>.from(dataList!.map((x) => x.toJson())),
      };
}

class AssessmentDetailModel {
  AssessmentDetailModel(
      {required this.assessmentId,
      required this.name,
      required this.description,
      required this.startDate,
      required this.startTime,
      required this.endDate,
      required this.endTime,
      required this.imageName,
      required this.duration,
      required this.companyId,
      required this.userScored});

  int assessmentId;
  String name;
  String description;
  String startDate;
  String startTime;
  String endDate;
  String endTime;
  String imageName;
  int duration;
  int companyId;
  AssessmentScoreModel? userScored;

  factory AssessmentDetailModel.fromRawJson(String str) =>
      AssessmentDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AssessmentDetailModel.fromJson(Map<String, dynamic> json) {
    final assessJson = json["assessmentResponse"];
    return AssessmentDetailModel(
        assessmentId: assessJson["assessmentId"],
        name: assessJson["name"],
        description: assessJson["description"],
        startDate: assessJson["startDate"],
        startTime: assessJson["startTime"],
        endDate: assessJson["endDate"],
        endTime: assessJson["endTime"],
        imageName: assessJson["imageName"],
        duration: assessJson["duration"],
        companyId: assessJson["companyId"],
        userScored: json["assessmentScoreResponse"] == null
            ? null
            : AssessmentScoreModel.fromJson(json["assessmentScoreResponse"]));
  }

  Map<String, dynamic> toJson() => {
        "assessmentScoreResponse": userScored?.toJson(),
        "assessmentResponse": {
          "assessmentId": assessmentId,
          "name": name,
          "description": description,
          "startDate": startDate,
          "startTime": startTime,
          "endDate": endDate,
          "endTime": endTime,
          "imageName": imageName,
          "duration": duration,
          "companyId": companyId,
        }
      };
}

class AssessmentQuestionsModel {
  AssessmentQuestionsModel({
    required this.message,
    required this.status,
    required this.data,
  });

  String message;
  String status;
  ResponseData? data;

  factory AssessmentQuestionsModel.fromRawJson(String str) =>
      AssessmentQuestionsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AssessmentQuestionsModel.fromJson(Map<String, dynamic> json) =>
      AssessmentQuestionsModel(
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

  List<AssessQuestionModel> questionData;

  factory ResponseData.fromRawJson(String str) =>
      ResponseData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
        questionData: List<AssessQuestionModel>.from(
            json["questionData"].map((x) => AssessQuestionModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "questionData": List<dynamic>.from(questionData.map((x) => x.toJson())),
      };
}

class AssessQuestionModel {
  AssessQuestionModel({
    required this.id,
    required this.assessmentId,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.questionType,
    required this.sequence,
  });

  int id;
  int assessmentId;
  String questionText;
  String correctAnswer;
  List<String> options;
  QuestionInputType questionType;
  int sequence;

  factory AssessQuestionModel.fromRawJson(String str) =>
      AssessQuestionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AssessQuestionModel.fromJson(Map<String, dynamic> json) =>
      AssessQuestionModel(
        id: json["id"],
        assessmentId: json["assessmentId"],
        questionText: json["questionText"],
        correctAnswer: json["correctAnswer"],
        options: List<String>.from(json["options"].map((x) => x)),
        questionType:
            QuestionInputType.singleLineText.fromString(json["questionType"]),
        sequence: json["sequence"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "assessmentId": assessmentId,
        "questionText": questionText,
        "correctAnswer": correctAnswer,
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
      assessmentQuestionDetails: this);
}

enum QuestionInputType {
  dropdown,
  amount,
  number,
  radio,
  image,
  boolean,
  singleLineText,
  multiLineText,
  ddMMyy
}

extension Helper on QuestionInputType {
  QuestionInputType fromString(String type) {
    switch (type) {
      case "QUESTION_WITH_OPTIONS_DROP_DOWN":
        return QuestionInputType.dropdown;
      case "QUESTION_WITH_OPTIONS_CHECK_BOX":
        return QuestionInputType.radio;
      case "QUESTION_WITH_TRUE_FALSE":
        return QuestionInputType.boolean;
      case "QUESTION_WITH_NUMERIC_ANSWER":
        return QuestionInputType.number;
      case "QUESTION_WITH_CORRECT_ANSWER":
        return QuestionInputType.singleLineText;

      default:
        return QuestionInputType.singleLineText;
    }
  }

  String toStringName() {
    switch (this) {
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
      case QuestionInputType.multiLineText:
        return "";
      case QuestionInputType.ddMMyy:
        return "";
      case QuestionInputType.amount:
        return "";
      case QuestionInputType.image:
        return "";
    }
  }
}

class AssessmentScoreModel {
  AssessmentScoreModel({
    required this.assessmentId,
    required this.userId,
    required this.assessmentCompletionTime,
    required this.assessmentScore,
    required this.wrongAnswer,
    required this.nonAttempted,
  });

  int assessmentId;
  int userId;
  int assessmentCompletionTime;
  int assessmentScore;
  int wrongAnswer;
  int nonAttempted;

  factory AssessmentScoreModel.fromRawJson(String str) =>
      AssessmentScoreModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AssessmentScoreModel.fromJson(Map<String, dynamic> json) =>
      AssessmentScoreModel(
        assessmentId: json["assessmentId"],
        userId: json["userId"],
        assessmentCompletionTime: json["assessmentCompletionTime"],
        assessmentScore: json["assessmentScore"],
        nonAttempted: json["nonAttempted"] ?? 0,
        wrongAnswer: json["wrongAnswer"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "assessmentId": assessmentId,
        "userId": userId,
        "assessmentCompletionTime": assessmentCompletionTime,
        "assessmentScore": assessmentScore,
        "nonAttempted": nonAttempted,
        "wrongAnswer": wrongAnswer,
      };
}
