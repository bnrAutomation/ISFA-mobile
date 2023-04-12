import 'dart:convert';

import 'package:i_densfa/utility/extensions.dart';

class MyActivityModel {
  MyActivityModel({
    required this.message,
    required this.status,
  });
  late final String message;
  late final int status;
  late final MyActivityData data;

  factory MyActivityModel.fromRawJson(String str) =>
      MyActivityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  MyActivityModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = int.parse(json['status'].toString());
    data = MyActivityData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['data'] = data;
    return data;
  }
}

class MyActivityData {
  MyActivityData({
    required this.attendanceData,
  });
  late final List<AttendanceData> attendanceData;

  MyActivityData.fromJson(Map<String, dynamic> json) {
    attendanceData = List.from(json['attendanceData'])
        .map((e) => AttendanceData.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['attendanceData'] = attendanceData.map((e) => e.toJson()).toList();
    return data;
  }
}

class AttendanceData {
  AttendanceData({
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.storeid,
    required this.timeSpan,
    required this.lastOutTime,
    required this.firstInTime,
    required this.dutyTimeSpan,
  });
  late final DateTime date;
  late final String inTime;
  late final String outTime;
  late final int? storeid;
  late final String timeSpan;
  late final String lastOutTime;
  late final String firstInTime;
  late final String dutyTimeSpan;

  AttendanceData.fromJson(Map<String, dynamic> json) {
    date = DateTime.parse(
        json['date'] ?? DateTime.now().toStringFormat("yyyy-MM-dd"));
    inTime = json['inTime'] ?? "";
    outTime = json['outTime'] ?? "";
    storeid = json['storeid'];
    timeSpan = json['timeSpan'] ?? "";
    lastOutTime = json['lastOutTime'] ?? "";
    firstInTime = json['firstInTime'] ?? "";
    dutyTimeSpan = json['dutyTimeSpan'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['inTime '] = inTime;
    data['outTime '] = outTime;
    data['storeid'] = storeid;
    data['timeSpan '] = timeSpan;
    data['lastOutTime'] = lastOutTime;
    data['firstInTime'] = firstInTime;
    data['dutyTimeSpan'] = dutyTimeSpan;
    return data;
  }
}
