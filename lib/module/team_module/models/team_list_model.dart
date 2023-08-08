import 'dart:convert';

import 'package:i_densfa/utility/extensions.dart';

class TeamListResponse {
  final String message;
  final int status;
  final List<TeamMemberModel> dataList;
  final TeamMemberModel supervisiorDetails;

  TeamListResponse({
    required this.message,
    required this.status,
    required this.dataList,
    required this.supervisiorDetails,
  });

  factory TeamListResponse.fromRawJson(String str) =>
      TeamListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamListResponse.fromJson(Map<String, dynamic> json) =>
      TeamListResponse(
          message: json["message"],
          status: json["status"],
          dataList: List<TeamMemberModel>.from(
              json["dataList"].map((x) => TeamMemberModel.fromJson(x))),
          supervisiorDetails:
              TeamMemberModel.fromJson(json["supervisiorDetails"]));

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "dataList": List<dynamic>.from(dataList.map((x) => x.toJson())),
        "supervisiorDetails": supervisiorDetails.toJson()
      };
}

class TeamMemberModel {
  final int userId;
  final String email;
  final String username;
  final String designation;
  final String role;
  final String mobile;
  final String uuid;
  final String? photoUrl;
  final DateTime doj;

  TeamMemberModel(
      {required this.userId,
      required this.email,
      required this.username,
      required this.designation,
      required this.role,
      required this.mobile,
      required this.uuid,
      required this.doj,
      required this.photoUrl});

  factory TeamMemberModel.fromRawJson(String str) =>
      TeamMemberModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) =>
      TeamMemberModel(
        userId: json["userId"],
        email: json["email"],
        username: json["username"],
        designation: json["designation"],
        role: json["role"],
        mobile: json["mobile"],
        uuid: json["uuid"],
        doj: DateTime.parse(json["doj"]),
        photoUrl: json["photoUrl"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "email": email,
        "username": username,
        "designation": designation,
        "role": role,
        "mobile": mobile,
        "uuid": uuid,
        "doj": doj.toStringFormat('yyyy-MM-dd'),
        "photoUrl": photoUrl,
      };
}
