import 'dart:convert';
import 'dart:core';

List<LeaveTypeModel> leaveTypeListfromBody(String body) {
  final j = json.decode(body);
  return List<LeaveTypeModel>.from(
      j["dataList"].map((x) => LeaveTypeModel.fromJson(x)));
}

class LeaveTypeModel {
  LeaveTypeModel({
    required this.leaveId,
    required this.leaveType,
    required this.leaveDesc,
    required this.specialLeave,
    required this.active,
  });

  int leaveId;
  String leaveType;
  String leaveDesc;
  bool specialLeave;
  bool active;

  factory LeaveTypeModel.fromRawJson(String str) =>
      LeaveTypeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) => LeaveTypeModel(
        leaveId: json["leaveId"],
        leaveType: json["leaveType"],
        leaveDesc: json["leaveDesc"],
        specialLeave: json["specialLeave"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "leaveId": leaveId,
        "leaveType": leaveType,
        "leaveDesc": leaveDesc,
        "specialLeave": specialLeave,
        "active": active,
      };
}
