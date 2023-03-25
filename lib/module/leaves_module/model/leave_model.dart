import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

enum LeaveType { casual, sick, weekOff, other }

enum LeaveStatus { request, approve, reject }

extension LeaveStatusHelper on LeaveStatus {
  LeaveStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'approved':
        return LeaveStatus.approve;
      case 'reject':
        return LeaveStatus.reject;
      default:
        return LeaveStatus.request;
    }
  }

  String toStr() {
    switch (this) {
      case LeaveStatus.request:
        return 'pending';
      case LeaveStatus.approve:
        return 'approved';
      case LeaveStatus.reject:
        return 'reject';
    }
  }
}

extension LeaveTypeHelper on LeaveType {
  // ignore: unused_element
  Color get refColor {
    switch (this) {
      case LeaveType.casual:
        return Colors.green;
      case LeaveType.sick:
        return Colors.red;
      case LeaveType.weekOff:
        return Colors.amber;
      case LeaveType.other:
        return Colors.black;
    }
  }

  LeaveType fromString(String val) {
    switch (val.toLowerCase().replaceAll('leave', '').replaceAll(' ', '')) {
      case 'sick':
        return LeaveType.sick;
      case 'casual':
        return LeaveType.sick;
      case 'weekoff':
        return LeaveType.weekOff;
      default:
        return LeaveType.other;
    }
  }

  String toStr() {
    switch (this) {
      case LeaveType.casual:
        return 'Casual leave';
      case LeaveType.sick:
        return 'Sick leave';
      case LeaveType.weekOff:
        return 'Week Off';
      case LeaveType.other:
        return 'Other';
    }
  }
}

class EmpLeaveDetailsModel {
  EmpLeaveDetailsModel({
    required this.totalLeave,
    required this.leaveBalance,
    required this.usedLeave,
    required this.leaveTypeBalance,
    required this.empAppliedLeave,
    required this.reporteeRequestedLeave,
  });

  int totalLeave;
  int leaveBalance;
  int usedLeave;
  List<LeaveBalanceModel> leaveTypeBalance;
  List<AppliedLeaveModel> empAppliedLeave;
  List<AppliedLeaveModel> reporteeRequestedLeave;

  factory EmpLeaveDetailsModel.fromRawJson(String str) =>
      EmpLeaveDetailsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EmpLeaveDetailsModel.fromJson(Map<String, dynamic> json) =>
      EmpLeaveDetailsModel(
        totalLeave: json["totalLeave"],
        leaveBalance:
            double.tryParse(json["leaveBalance"].toString())?.toInt() ?? 0,
        usedLeave: double.tryParse(json["usedLeave"].toString())?.toInt() ?? 0,
        leaveTypeBalance: List<LeaveBalanceModel>.from(
            json["leaveTypeBalance"].map((x) => LeaveBalanceModel.fromJson(x))),
        empAppliedLeave: List<AppliedLeaveModel>.from(
            json["empAppliedLeave"].map((x) => AppliedLeaveModel.fromJson(x))),
        reporteeRequestedLeave: List<AppliedLeaveModel>.from(
            json["reporteeRequestedLeave"]
                .map((x) => AppliedLeaveModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "totalLeave": totalLeave,
        "leaveBalance": leaveBalance,
        "usedLeave": usedLeave,
        "leaveTypeBalance":
            List<dynamic>.from(leaveTypeBalance.map((x) => x.toJson())),
        "empAppliedLeave":
            List<dynamic>.from(empAppliedLeave.map((x) => x.toJson())),
        "reporteeRequestedLeave":
            List<dynamic>.from(reporteeRequestedLeave.map((x) => x.toJson())),
      };
}

class AppliedLeaveModel {
  AppliedLeaveModel({
    required this.leaveStatus,
    this.leaveType,
    required this.fromDate,
    required this.toDate,
    this.userName,
  });

  LeaveStatus leaveStatus;
  LeaveType? leaveType;
  DateTime fromDate;
  DateTime toDate;
  String? userName;

  factory AppliedLeaveModel.fromRawJson(String str) =>
      AppliedLeaveModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppliedLeaveModel.fromJson(Map<String, dynamic> json) =>
      AppliedLeaveModel(
        leaveStatus: LeaveStatus.request.fromString(json["leaveStatus"]),
        leaveType: LeaveType.other.fromString(json["leaveType"] ?? ''),
        fromDate: DateTime.parse(json["fromDate"]),
        toDate: DateTime.parse(json["toDate"]),
        userName: json["userName"],
      );

  Map<String, dynamic> toJson() => {
        "leaveStatus": leaveStatus.toStr(),
        "leaveType": leaveType?.toStr(),
        "fromDate": DateFormat('yyyy-MM-dd').format(fromDate),
        "toDate": DateFormat('yyyy-MM-dd').format(toDate),
        "userName": userName,
      };
}

class LeaveBalanceModel {
  LeaveBalanceModel({
    required this.leaveTypeName,
    required this.leaveTypeBalance,
    this.leaveTypeColor,
    this.leaveTypeIcon,
  });

  String leaveTypeName;
  int leaveTypeBalance;
  String? leaveTypeColor;
  String? leaveTypeIcon;

  factory LeaveBalanceModel.fromRawJson(String str) =>
      LeaveBalanceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) =>
      LeaveBalanceModel(
        leaveTypeName: json["leaveTypeName"],
        leaveTypeBalance:
            double.tryParse(json["leaveTypeBalance"].toString())?.toInt() ?? 0,
        leaveTypeColor: json["leaveTypeColor"],
        leaveTypeIcon: json["leaveTypeIcon"],
      );

  Map<String, dynamic> toJson() => {
        "leaveTypeName": leaveTypeName,
        "leaveTypeBalance": leaveTypeBalance,
        "leaveTypeColor": leaveTypeColor,
        "leaveTypeIcon": leaveTypeIcon,
      };
}
