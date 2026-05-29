// To parse this JSON data, do
//
//     final teamDataResponse = teamDataResponseFromJson(jsonString);

import 'dart:convert';

class TeamDataResponse {
  final String message;
  final int status;
  final TeamDataModel data;

  TeamDataResponse({
    required this.message,
    required this.status,
    required this.data,
  });

  factory TeamDataResponse.fromRawJson(String str) =>
      TeamDataResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamDataResponse.fromJson(Map<String, dynamic> json) =>
      TeamDataResponse(
        message: json["message"],
        status: json["status"],
        data: TeamDataModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "data": data.toJson(),
      };
}

class TeamDataModel {
  final int activeToday;
  final int totalMembersAdded;
  final int noRecentLogin;

  TeamDataModel({
    required this.activeToday,
    required this.totalMembersAdded,
    required this.noRecentLogin,
  });

  factory TeamDataModel.fromRawJson(String str) =>
      TeamDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamDataModel.fromJson(Map<String, dynamic> json) => TeamDataModel(
        activeToday: json["activeToday"],
        totalMembersAdded: json["totalMembersAdded"],
        noRecentLogin: json["noRecentLogin"],
      );

  Map<String, dynamic> toJson() => {
        "activeToday": activeToday,
        "totalMembersAdded": totalMembersAdded,
        "noRecentLogin": noRecentLogin,
      };
}
