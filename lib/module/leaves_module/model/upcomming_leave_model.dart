import 'dart:convert';

import 'package:i_densfa/utility/extensions.dart';

class UpcommingLeaveModel {
  UpcommingLeaveModel({
    required this.message,
    required this.status,
    required this.dataList,
  });
  late final String message;
  late final String status;
  late final List<DataList> dataList;
  late final DataList? data;

  factory UpcommingLeaveModel.fromRawJson(String str) =>
      UpcommingLeaveModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  UpcommingLeaveModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    data = json['data'] != null ? DataList.fromJson(json['data']) : null;
    dataList = json['dataList'] != null
        ? List.from(json['dataList']).map((e) => DataList.fromJson(e)).toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final valueData = <String, dynamic>{};
    valueData['message'] = message;
    valueData['status'] = status;
    valueData['dataList'] = dataList.map((e) => e.toJson()).toList();
    valueData['data'] = data?.toJson();
    return valueData;
  }
}

class DataList {
  DataList({
    required this.month,
    required this.days,
  });
  late final String month;
  late final int availableLeave;
  late final List<LeaveDays> days;

  DataList.fromJson(Map<String, dynamic> json) {
    month = json['month'] ?? "";
    availableLeave = json['availableLeave'] ?? 0;
    days = List.from(json['days'] ?? [])
        .map((e) => LeaveDays.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['month'] = month;
    data['availableLeave'] = availableLeave;
    data['days'] = days.map((e) => e.toJson()).toList();
    return data;
  }
}

class LeaveDays {
  LeaveDays({
    required this.day,
    required this.date,
    required this.occasion,
    required this.region,
  });
  late final String day;
  late final DateTime? date;
  late final String occasion;
  late final String region;
  bool isActive = false;
  bool canChange = true;

  LeaveDays.fromJson(Map<String, dynamic> json) {
    day = json['day'] ?? "";
    date = json['date'] != null ? DateTime.parse(json["date"]) : null;
    occasion = json['occasion'] ?? "";
    region = json['region'] ?? "";
    isActive = json['isActive'] ?? false;
    canChange = json['canChange'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['day'] = day;
    data['date'] = date?.toStringFormat('yyyy-MM-dd');
    data['occasion'] = occasion;
    data['region'] = region;
    data['isActive'] = isActive;
    data['canChange'] = canChange;
    return data;
  }
}
