import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:i_densfa/module/attendance_module/model/attendance_request_model.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'model/attendance_model.dart';

class AttendanceRepository {
  final int userId;
  final client = CustomHttpBaseClient.instance;
  AttendanceRepository(int? forUserId)
      : userId = forUserId ?? AppStorage().userDetail!.id;

  Future<List<AttandanceDataNew>> getUserAttendance({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final response = await client.get(
        Uri.parse('${URLConstants.attendence}/V2/$userId')
            .replace(queryParameters: {
      'startDate': fromDate.toStringFormat("yyyy-MM-dd"),
      'endDate': toDate.toStringFormat("yyyy-MM-dd")
    }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return <AttandanceDataNew>[];
      } else {
        final attandance = AttandanceModelNew.fromRawJson(response.body);
        return attandance.data;
      }
    } else if (response.statusCode == 401) {
      throw "Session Expired. Please Login again.";
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<AttendanceRequestData>> getAttendanceRequest(
      {required DateTime dateTime}) async {
    final response = await client.get(Uri.parse(
        '${URLConstants.attendenceRequest}/$userId/${dateTime.toStringFormat('yyyy')}/${dateTime.toStringFormat('MM')}'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body.isEmpty
          ? <AttendanceRequestData>[]
          : AttendanceRequest.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> applyAttendance({
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
    required TimeOfDay fromTime,
    required TimeOfDay toTime,
  }) async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    final body = {
      "userId": userId,
      // "startDate": fromDate.toStringFormat('yyyy-MM-dd'),
      // "endDate": toDate.toStringFormat('yyyy-MM-dd'),
      "inDate": fromDate.toStringFormat('yyyy-MM-dd'),
      "outDate": toDate.toStringFormat('yyyy-MM-dd'),
      "helthStatus": null,
      "inTime": fromTime.toStringFormat("HH:mm:ss"),
      "outTime": toTime.toStringFormat("HH:mm:ss"),

      // "startTime": fromTime.toStringFormat("HH:mm:ss"),
      // "endTime": toTime.toStringFormat("HH:mm:ss"),
      "i18nStartTime": DateTime(fromDate.year, fromDate.month, fromDate.day,
              fromTime.hour, fromTime.minute)
          .toUtc()
          .toString(),
      "i18nEndTime": DateTime(
              toDate.year, toDate.month, toDate.day, toTime.hour, toTime.minute)
          .toUtc()
          .toString(),
      // "localStart": DateTime(fromDate.year, fromDate.month, fromDate.day,
      //         fromTime.hour, fromTime.minute)
      //     .toLocal().toLocal(),
      // "localEnd": DateTime(
      //         toDate.year, toDate.month, toDate.day, toTime.hour, toTime.minute)
      //     .toLocal().toString(),
      "reason": reason,
      "timeZone": currentTimeZone,
      "storeId": "-1"
    };
    if (kDebugMode) {
      debugPrint(jsonEncode(body));
    }
    final response = await client.post(Uri.parse(URLConstants.bulkattendance),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> attendanceAction(
      bool isAccepted, List<int> leaveRequestIds) async {
    final body = {
      "attendanceRequestIds": leaveRequestIds,
      "status": isAccepted ? "approved" : "rejected",
      "supervisorUserId": userId.toString()
    };
    final response = await client.post(
        Uri.parse(URLConstants.attendanceApprove),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<DateTime>> getLeaveDates() async {
    final response = await client
        .get(Uri.parse('${URLConstants.attandanceLeave}/$userId/dates'));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((dateStr) => DateTime.parse(dateStr))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }
}
