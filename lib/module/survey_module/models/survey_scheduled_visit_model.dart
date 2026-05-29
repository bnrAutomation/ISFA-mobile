import 'dart:convert';

class SurveyScheduledVisitModel {
  final int id;
  final int userId;
  final String surveyUuid;
  final String clientName;
  final DateTime visitDate;
  final String agenda;

  SurveyScheduledVisitModel({
    required this.id,
    required this.userId,
    required this.surveyUuid,
    required this.clientName,
    required this.visitDate,
    required this.agenda,
  });

  factory SurveyScheduledVisitModel.fromRawJson(String str) =>
      SurveyScheduledVisitModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SurveyScheduledVisitModel.fromJson(Map<String, dynamic> json) =>
      SurveyScheduledVisitModel(
        id: json["id"],
        userId: json["userId"],
        surveyUuid: json["surveyUuid"],
        clientName: json["clientName"],
        visitDate: DateTime.parse(json["visitDate"]),
        agenda: json["agenda"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "surveyUuid": surveyUuid,
        "clientName": clientName,
        "visitDate":
            "${visitDate.year.toString().padLeft(4, '0')}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}",
        "agenda": agenda,
      };
}
