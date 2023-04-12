import 'dart:convert';

class MyActivityModel {
  MyActivityModel(
      {required this.message, required this.status, required this.data});
  final String message;
  final int status;
  final MyActivityData data;

  factory MyActivityModel.fromRawJson(String str) =>
      MyActivityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MyActivityModel.fromJson(Map<String, dynamic> json) =>
      MyActivityModel(
          message: json['message'],
          status: int.parse(json['status'].toString()),
          data: MyActivityData.fromJson(json['data']));

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['data'] = data;
    return data;
  }
}

class MyActivityData {
  MyActivityData({required this.attendanceData});
  final List<AttendanceData> attendanceData;

  factory MyActivityData.fromJson(Map<String, dynamic> json) => MyActivityData(
      attendanceData: List.from(json['attendanceData'])
          .map((e) => AttendanceData.fromJson(e))
          .toList());

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
  final DateTime date;
  final String inTime;
  final String outTime;
  final int? storeid;
  final String timeSpan;
  final String lastOutTime;
  final String firstInTime;
  final String dutyTimeSpan;

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
      date:
          json['date'] == null ? DateTime.now() : DateTime.parse(json['date']),
      inTime: json['inTime'] ?? "",
      outTime: json['outTime'] ?? "",
      storeid: json['storeid'],
      timeSpan: json['timeSpan'] ?? "",
      lastOutTime: json['lastOutTime'] ?? "",
      firstInTime: json['firstInTime'] ?? "",
      dutyTimeSpan: json['dutyTimeSpan'] ?? "");

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
