import 'dart:convert';

class FilledSurveyApiResponse {
  FilledSurveyApiResponse({
    required this.message,
    required this.status,
    required this.surveyResponse,
    required this.totalPages,
    required this.totalRecords,
    required this.pageSize,
  });
  late final String message;
  late final int status;
  late final FilledSurveyResponse surveyResponse;
  late final int totalPages;
  late final int totalRecords;
  late final int pageSize;

  factory FilledSurveyApiResponse.fromRawJson(String str) =>
      FilledSurveyApiResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  FilledSurveyApiResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    surveyResponse = FilledSurveyResponse.fromJson(json['data']);
    totalPages = json['totalPages'];
    totalRecords = json['totalRecords'];
    pageSize = json['pageSize'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['data'] = surveyResponse.toJson();
    data['totalPages'] = totalPages;
    data['totalRecords'] = totalRecords;
    data['pageSize'] = pageSize;
    return data;
  }
}

class FilledSurveyResponse {
  final String staticAttribute;
  String? dynamicAttribute;
  final List<FilledSurveyUserResponse> userResponse;

  FilledSurveyResponse({
    required this.staticAttribute,
    required this.dynamicAttribute,
    required this.userResponse,
  });

  factory FilledSurveyResponse.fromRawJson(String str) =>
      FilledSurveyResponse.fromJson(json.decode(str)['data']);

  String toRawJson() => json.encode(toJson());

  factory FilledSurveyResponse.fromJson(Map<String, dynamic> json) =>
      FilledSurveyResponse(
        staticAttribute: json["staticAttribute"] ?? "",
        dynamicAttribute: json["dynamicAttribute"],
        userResponse: List<FilledSurveyUserResponse>.from(json["userResponse"]
            .map((x) => FilledSurveyUserResponse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "staticAttribute": staticAttribute,
        "dynamicAttribute": dynamicAttribute,
        "userResponse": List<dynamic>.from(userResponse.map((x) => x.toJson())),
      };
}

class FilledSurveyUserResponse {
  final String uuid;
  final String surveyUuid;
  final String clientName;
  final String image;
  final int userId;
  final String responseStatus;
  final DateTime createdDate;
  final List<FilledSurveyQuestionResponse> questionResponse;

  FilledSurveyUserResponse({
    required this.uuid,
    required this.surveyUuid,
    required this.clientName,
    required this.image,
    required this.userId,
    required this.responseStatus,
    required this.createdDate,
    required this.questionResponse,
  });

  factory FilledSurveyUserResponse.fromRawJson(String str) =>
      FilledSurveyUserResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FilledSurveyUserResponse.fromJson(Map<String, dynamic> json) =>
      FilledSurveyUserResponse(
        uuid: json["uuid"],
        surveyUuid: json["surveyUuid"],
        clientName: json["clientName"],
        image: json["image"] ?? "",
        userId: json["userId"],
        responseStatus: json["responseStatus"],
        createdDate: DateTime.parse(json["createdDate"]),
        questionResponse: List<FilledSurveyQuestionResponse>.from(
            json["questionResponse"]
                .map((x) => FilledSurveyQuestionResponse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "surveyUuid": surveyUuid,
        "clientName": clientName,
        "image": image,
        "userId": userId,
        "responseStatus": responseStatus,
        "createdDate":
            "${createdDate.year.toString().padLeft(4, '0')}-${createdDate.month.toString().padLeft(2, '0')}-${createdDate.day.toString().padLeft(2, '0')}",
        "questionResponse":
            List<dynamic>.from(questionResponse.map((x) => x.toJson())),
      };
}

class FilledSurveyQuestionResponse {
  final String questionName;
  final String questionUuid;
  final String answer;
  bool isActive = true;

  FilledSurveyQuestionResponse(
      {required this.questionName,
      required this.questionUuid,
      required this.answer,
      this.isActive = true});

  factory FilledSurveyQuestionResponse.fromRawJson(String str) =>
      FilledSurveyQuestionResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FilledSurveyQuestionResponse.fromJson(Map<String, dynamic> json) =>
      FilledSurveyQuestionResponse(
          questionName: json["questionName"] ?? "",
          questionUuid: json["questionUuid"] ?? "",
          answer: json["answer"] ?? "",
          isActive: json["isActive"] ?? true);

  Map<String, dynamic> toJson() => {
        "questionName": questionName,
        "questionUuid": questionUuid,
        "answer": answer,
        "isActive": isActive
      };
}
