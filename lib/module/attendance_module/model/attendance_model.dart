import 'dart:convert';

import 'package:intl/intl.dart';

class AttandanceModelNew {
  AttandanceModelNew({
    required this.data,
    required this.success,
  });
  late final List<AttandanceDataNew> data;
  late final bool success;

    factory AttandanceModelNew.fromRawJson(String str) =>
      AttandanceModelNew.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
  
  AttandanceModelNew.fromJson(Map<String, dynamic> json){
    data = List.from(json['data']??[]).map((e)=>AttandanceDataNew.fromJson(e)).toList();
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final jsondata = <String, dynamic>{};
    jsondata['data'] = data.map((e)=>e.toJson()).toList();
    jsondata['success'] = success;
    return jsondata;
  }
}

class AttandanceDataNew {
  AttandanceDataNew({
    required this.date,
    required this.startDutyTime,
    required this.endDutyTime,
    required this.firstMarkInTime,
    required this.lastMarkOutTime,
    required this.spanInhr,
  });
  late final DateTime date;
  late final String startDutyTime;
  late final String endDutyTime;
  late final String firstMarkInTime;
  late final String lastMarkOutTime;
  late final String spanInhr;
  
  AttandanceDataNew.fromJson(Map<String, dynamic> json){
    date = DateTime.parse(json["date"]);
    startDutyTime = json['startDutyTime']??'-';
    endDutyTime = json['endDutyTime']??'-';
    firstMarkInTime = json['firstMarkInTime']??'-';
    lastMarkOutTime = json['lastMarkOutTime']??'-';
    spanInhr = json['spanInhr']??'-';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['startDutyTime'] = startDutyTime;
    data['endDutyTime'] = endDutyTime;
    data['firstMarkInTime'] = firstMarkInTime;
    data['lastMarkOutTime'] = lastMarkOutTime;
    data['spanInhr'] = spanInhr;
    return data;
  }
}


class AttendanceModel {
  AttendanceModel(
      {required this.message, required this.status, required this.data});
  final String message;
  final int status;
  final List<AttendanceData> data;
  

  factory AttendanceModel.fromRawJson(String str) =>
      AttendanceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
          message: json['message'],
          status: int.parse(json['status'].toString()),
          data: (json['data'] as List)
            .map((item) => AttendanceData.fromJson(item))
            .toList(),
              );

  Map<String, dynamic> toJson() => {
        'message': message,
        'status': status,
        'data': data.map((e) => e.toJson()).toList()
      };
}

class AttendanceData {
  AttendanceData(
      {required this.date,
      required this.startDutyTime,
      required this.endDutyTime,
      required this.firstMarkInTime,
      required this.lastMarkOutTime,
      required this.timeSpan,
      this.i18nStartTime,
      this.i18nEndTime,
      required this.leaveType,
      required this.status,
      this.firstI18nMarkInTime,
      this.lastI18nMarkOutTime,
      required this.leaves});

  DateTime date;
  String? startDutyTime;
  String? endDutyTime;
  String? firstMarkInTime;
  String? lastMarkOutTime;
  String? timeSpan;
  String status;
  String leaveType;

  DateTime? i18nStartTime;
  DateTime? i18nEndTime;
  DateTime? firstI18nMarkInTime;
  DateTime? lastI18nMarkOutTime;
  List<Leaves> leaves = [];

  factory AttendanceData.fromRawJson(String str) =>
      AttendanceData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
      date: DateTime.parse(json["date"]),
      startDutyTime: json["startDutyTime"],
      endDutyTime: json["endDutyTime"],
      firstMarkInTime: json["firstMarkInTime"],
      lastMarkOutTime: json["lastMarkOutTime"],
      timeSpan: json["timeSpan"],
      leaveType: json["leaveType"] ?? "",
      status: json["status"] ?? "Absent",
      leaves: List.from(json['leaves'] ?? [])
          .map((e) => Leaves.fromJson(e))
          .toList(),
      i18nStartTime: json["i18nStartTime"] == null ||
              json["i18nStartTime"].toString().isEmpty
          ? null
          : DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(json["i18nStartTime"], true)
              .toLocal(),
      i18nEndTime:
          json["i18nEndTime"] == null || json["i18nEndTime"].toString().isEmpty
              ? null
              : DateFormat("yyyy-MM-dd HH:mm:ss")
                  .parse(json["i18nEndTime"], true)
                  .toLocal(),
      //DateTime.parse(json["i18nEndTime"])

      firstI18nMarkInTime: json["firstI18nMarkInTime"] == null ||
              json["firstI18nMarkInTime"].toString().isEmpty
          ? null
          : DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(json["firstI18nMarkInTime"], true)
              .toLocal(),
      lastI18nMarkOutTime: json["lastI18nMarkOutTime"] == null ||
              json["lastI18nMarkOutTime"].toString().isEmpty
          ? null
          : DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(json["lastI18nMarkOutTime"], true)
              .toLocal());

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "startDutyTime": startDutyTime,
        "endDutyTime": endDutyTime,
        "firstMarkInTime": firstMarkInTime,
        "lastMarkOutTime": lastMarkOutTime,
        "timeSpan": timeSpan,
        "status": status,
        "leaveType": leaveType,
        'leaves': leaves.map((e) => e.toJson()).toList()
      };
}

class Leaves {
  Leaves({
    required this.leaveType,
    required this.dayId,
  });
  late final String leaveType;
  late final int dayId;

  Leaves.fromJson(Map<String, dynamic> json) {
    leaveType = json['leaveType'];
    dayId = json['dayId'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['leaveType'] = leaveType;
    data['dayId'] = dayId;
    return data;
  }
}
