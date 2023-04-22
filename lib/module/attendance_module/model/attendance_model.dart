import 'dart:convert';

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
              .map((e) => AttendanceData.fromJson(e))
              .toList());

  Map<String, dynamic> toJson() => {
        'message': message,
        'status': status,
        'data': data.map((e) => e.toJson()).toList()
      };
}

class AttendanceData {
  AttendanceData({
    required this.date,
    required this.startDutyTime,
    required this.endDutyTime,
    required this.firstMarkInTime,
    required this.lastMarkOutTime,
    required this.timeSpan,
  });

  DateTime date;
  String? startDutyTime;
  String? endDutyTime;
  String? firstMarkInTime;
  String? lastMarkOutTime;
  String? timeSpan;

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
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "startDutyTime": startDutyTime,
        "endDutyTime": endDutyTime,
        "firstMarkInTime": firstMarkInTime,
        "lastMarkOutTime": lastMarkOutTime,
        "timeSpan": timeSpan,
      };
}
