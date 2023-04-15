import 'dart:convert';

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
        dataList: List<AssessmentDetailModel>.from(
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
  AssessmentDetailModel({
    required this.assessmentId,
    required this.name,
    required this.description,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.imageName,
    required this.duration,
    required this.companyId,
  });

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

  factory AssessmentDetailModel.fromRawJson(String str) =>
      AssessmentDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AssessmentDetailModel.fromJson(Map<String, dynamic> json) =>
      AssessmentDetailModel(
        assessmentId: json["assessmentId"],
        name: json["name"],
        description: json["description"],
        startDate: json["startDate"],
        startTime: json["startTime"],
        endDate: json["endDate"],
        endTime: json["endTime"],
        imageName: json["imageName"],
        duration: json["duration"],
        companyId: json["companyId"],
      );

  Map<String, dynamic> toJson() => {
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
        return "QUESTION_WITH_DROP_DOWN";
      case QuestionInputType.amount:
        return "";
      case QuestionInputType.number:
        return "QUESTION_WITH_CORRECT_ANSWER";
      case QuestionInputType.radio:
        return "QUESTION_WITH_TRUE_FALSE";
      case QuestionInputType.image:
        return "";
      case QuestionInputType.boolean:
        return "QUESTION_WITH_TRUE_FALSE";
      case QuestionInputType.singleLineText:
        return "QUESTION_WITH_CORRECT_ANSWER";
      case QuestionInputType.multiLineText:
        return "";
      case QuestionInputType.ddMMyy:
        return "";
    }
  }
}
