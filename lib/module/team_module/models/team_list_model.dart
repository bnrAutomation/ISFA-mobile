import 'dart:convert';

class TeamListResponse {
  final String message;
  final int status;
  final List<TeamMemberModel> dataList;

  TeamListResponse({
    required this.message,
    required this.status,
    required this.dataList,
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
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "dataList": List<dynamic>.from(dataList.map((x) => x.toJson())),
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
  final DateTime doj;

  TeamMemberModel({
    required this.userId,
    required this.email,
    required this.username,
    required this.designation,
    required this.role,
    required this.mobile,
    required this.uuid,
    required this.doj,
  });

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
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "email": email,
        "username": username,
        "designation": designation,
        "role": role,
        "mobile": mobile,
        "uuid": uuid,
        "doj":
            "${doj.year.toString().padLeft(4, '0')}-${doj.month.toString().padLeft(2, '0')}-${doj.day.toString().padLeft(2, '0')}",
      };
}
