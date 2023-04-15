import 'dart:convert';
import 'package:i_densfa/utility/extensions.dart';

import 'leave_enums.dart';

class EmpLeaveDetailsModel {
  EmpLeaveDetailsModel({
    required this.totalLeave,
    required this.leaveBalance,
    required this.usedLeave,
    required this.leaveTypeBalance,
    required this.empAppliedLeave,
    required this.reporteeRequestedLeave,
  });

  double totalLeave;
  double leaveBalance;
  double usedLeave;
  List<LeaveBalanceModel> leaveTypeBalance;
  List<AppliedLeaveModel> empAppliedLeave;
  List<AppliedLeaveModel> reporteeRequestedLeave;

  factory EmpLeaveDetailsModel.fromRawJson(String str) =>
      EmpLeaveDetailsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EmpLeaveDetailsModel.fromJson(Map<String, dynamic> json) =>
      EmpLeaveDetailsModel(
        totalLeave: double.tryParse(json["totalLeave"].toString()) ?? 0.0,
        leaveBalance: double.tryParse(json["leaveBalance"].toString()) ?? 0.0,
        usedLeave: double.tryParse(json["usedLeave"].toString()) ?? 0,
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
  AppliedLeaveModel(
      {required this.leaveStatus,
      this.leaveType,
      required this.fromDate,
      required this.toDate,
      this.userName,
      this.leaveRequestId,
      this.reason});

  LeaveStatus leaveStatus;
  String? leaveType;
  DateTime fromDate;
  DateTime toDate;
  String? userName;
  int? leaveRequestId;
  String? reason;

  factory AppliedLeaveModel.fromRawJson(String str) =>
      AppliedLeaveModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppliedLeaveModel.fromJson(Map<String, dynamic> json) =>
      AppliedLeaveModel(
          leaveStatus: LeaveStatus.pending.fromString(json["leaveStatus"]),
          leaveType: json["leaveType"],
          fromDate: DateTime.parse(json["fromDate"]),
          toDate: DateTime.parse(json["toDate"]),
          userName: json["userName"],
          leaveRequestId: json['leaveRequestId'],
          reason: json['reason']);

  Map<String, dynamic> toJson() => {
        "leaveStatus": leaveStatus.toStr(),
        "leaveType": leaveType,
        "fromDate": fromDate.toStringFormat('yyyy-MM-dd'),
        "toDate": toDate.toStringFormat('yyyy-MM-dd'),
        "userName": userName,
        'leaveRequestId': leaveRequestId,
        'reason': reason
      };
}

class LeaveBalanceModel {
  LeaveBalanceModel({
    required this.leaveTypeName,
    required this.leaveTypeBalance,
    required this.leaveTypeColor,
    this.leaveTypeIcon,
  });

  String leaveTypeName;
  int leaveTypeBalance;
  String leaveTypeColor;
  String? leaveTypeIcon;

  factory LeaveBalanceModel.fromRawJson(String str) =>
      LeaveBalanceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) =>
      LeaveBalanceModel(
        leaveTypeName: json["leaveTypeName"],
        leaveTypeBalance:
            double.tryParse(json["leaveTypeBalance"].toString())?.toInt() ?? 0,
        leaveTypeColor: json["leaveTypeColor"] ?? "#FFFFFF",
        leaveTypeIcon: json["leaveTypeIcon"],
      );

  Map<String, dynamic> toJson() => {
        "leaveTypeName": leaveTypeName,
        "leaveTypeBalance": leaveTypeBalance,
        "leaveTypeColor": leaveTypeColor,
        "leaveTypeIcon": leaveTypeIcon,
      };
}
