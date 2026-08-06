import 'dart:convert';

import 'package:i_densfa/utility/extensions.dart';
import 'package:intl/intl.dart';

class AttendanceRequest {
  AttendanceRequest({
    required this.data,
  });
  late final List<AttendanceRequestData> data;

  factory AttendanceRequest.fromRawJson(String str) =>
      AttendanceRequest.fromJson(json.decode(str));

  AttendanceRequest.fromJson(Map<String, dynamic> json) {
    data = List.from(json['data'] ?? [])
        .map((e) => AttendanceRequestData.fromJson(e))
        .toList();
  }
}

class AttendanceRequestData {
  AttendanceRequestData(
      {required this.healthStatus,
      required this.attendanceId,
      required this.inDate,
      required this.userId,
      required this.fullName,
      required this.i18nStartTime,
      required this.i18nEndTime,
      
      required this.reason});
  late bool? healthStatus;
  late final int attendanceId;
  late final DateTime inDate;
  late final int userId;
  late final String fullName;
  late final DateTime i18nStartTime;
  late final DateTime i18nEndTime;
  late final String reason;
  late final String attendanceType;
  bool isSeleted=false;

  AttendanceRequestData.fromJson(Map<String, dynamic> json) {
    healthStatus = json['healthStatus'] == null
        ? null
        : json['healthStatus'] == "approved"
            ? true
            : false;
    attendanceId = json['attendanceId'];
    inDate = DateTime.parse(json["inDate"]);
    userId = json['userId'];
    fullName = json["full_name"] ?? "";
    i18nStartTime = DateFormat("yyyy-MM-dd HH:mm:ss")
        .parse(json["i18nStartTime"], true)
        .toLocal();
    i18nEndTime = DateFormat("yyyy-MM-dd HH:mm:ss")
        .parse(json["i18nEndTime"], true)
        .toLocal();
    reason = json["reason"] ?? "";
    attendanceType = json["attendanceType"]??"NA";
    isSeleted=json["isSeleted"]??false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['healthStatus'] = healthStatus;
    data['attendanceId'] = attendanceId;
    data['inDate'] = inDate.toStringFormat('yyyy-MM-dd');
    data['userId'] = userId;
    data['full_name'] = fullName;
    data['reason'] = reason;
    data["isSeleted"]=isSeleted;
    data["attendanceType"] =  attendanceType;
    return data;
  }
}
