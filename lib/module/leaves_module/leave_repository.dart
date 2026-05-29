import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:i_densfa/module/leaves_module/model/upcomingmodel.dart';
import 'package:i_densfa/module/leaves_module/model/upcomming_leave_model.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/leaves_module/model/leave_enums.dart';
import 'package:i_densfa/module/leaves_module/model/leave_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'model/leave_type_model.dart';

class LeaveRepository {
  final empId = AppStorage().userDetail!.id;
  final tages = AppStorage().userDetail!.tags;
  final companyId = AppStorage().homeInfo!.userInfo.companyId;
  final client = CustomHttpBaseClient.instance;
  
  Future<EmpLeaveDetailsModel> getDetails() async {
    final response = await client
        .get(Uri.parse('${URLConstants.leaveDetails}/$empId/$companyId'));
    if (response.statusCode == 200) {
      return EmpLeaveDetailsModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<EmpLeaveDetailsModel> getLeaveBalance() async {
    final response = await client.get(Uri.parse(
        '${URLConstants.getEmpLeaveBalanceDetails}/$empId/$companyId'));
    if (response.statusCode == 200) {
      return EmpLeaveDetailsModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<WeekOffModel>> getWeekOffLeave() async {
    final response =
        await client.get(Uri.parse("${URLConstants.weekoffleaves}/$empId"));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => WeekOffModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<DataList?> getOptionalLeave() async {
    final response = await client.get(Uri.parse(URLConstants.optionalleaves));
    if (response.statusCode == 200) {
      final data = UpcommingLeaveModel.fromRawJson(response.body).data;
      List<LeaveDays> appliedList = await getUserOptionalLeave();
      for (var applyElement in appliedList) {
        try {
          data?.days
              .firstWhere(
                (element) =>
                    element.date?.isSameDate(applyElement.date!) ?? false,
              )
              .isActive = true;
        } catch (e) {
          e.toString();
        }

        try {
          data?.days
              .firstWhere((element) =>
                  element.date?.isSameDate(applyElement.date!) ?? false)
              .canChange = false;
        } catch (e) {
          e.toString();
        }
      }
      return data;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<LeaveDays>> getUserOptionalLeave() async {
    final response =
        await client.get(Uri.parse("${URLConstants.optionalleaves}/$empId"));
    if (response.statusCode == 200) {
      return UpcommingLeaveModel.fromRawJson(response.body).data?.days ?? [];
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<UpcomingModel>> getUpcommingLeave() async {
    final response =
        await client.get(Uri.parse("${URLConstants.upcommingLeave}/$empId"));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => UpcomingModel.fromJson(e))
          .toList()
          .where((element) => element.date!.isAfter(DateTime.now()))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<LeaveApplyResposne> applyOptionalLeave(Map<String, List<LeaveDays>> map) async {
    final response = await client.post(
        Uri.parse("${URLConstants.saveoptionalleaves}/$empId"),
        body: jsonEncode(map),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201 || response.statusCode == 200) {
      return LeaveApplyResposne.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<LeaveApplyResposne> applyLeave(
      {required int leaveTypeId,
      required int dayId,
      required DateTime fromDate,
      required DateTime toDate,
      required String reason,
      DateTime? maternityDate}) async {
    var body = {
      "companyId": companyId,
      "userId": empId,
      "leaveId": leaveTypeId,
      "dayId": dayId,
      "leaveStatus": LeaveStatus.pending.toStr(),
      "dateFrom": fromDate.toStringFormat('yyyy-MM-dd'),
      "dateTo": toDate.toStringFormat('yyyy-MM-dd'),
      "reason": reason,
      "lwpFlag": "No",
    };
    if (maternityDate != null) {
      body.addAll({
        "expectedDateOfDelivery": maternityDate.toStringFormat('yyyy-MM-dd')
      });
    }
    if (kDebugMode) {
      debugPrint(jsonEncode(body));
    }
    final response = await client.post(Uri.parse(URLConstants.applyLeave),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201 || response.statusCode == 200) {
      return LeaveApplyResposne.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> leaveAction(bool isApproved, int id) async {
    final body = {
      "leaveStatus": isApproved
          ? LeaveStatus.approved.toStr()
          : LeaveStatus.rejected.toStr(),
      "leaveRequestId": id
    };

    final response = await client.put(
        Uri.parse('${URLConstants.leaveRequest}/$empId'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    final response = await client.get(Uri.parse(URLConstants.leaves));
    return leaveTypeListfromBody(response.body);
  }

     Future<List<DateTime>> getLeaveDates() async {
    final response = await client.get(
        Uri.parse('${URLConstants.attandanceLeave}/$empId/dates'));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
      .map((dateStr) => DateTime.parse(dateStr))
      .toList();
    } else {
      throw getErrorMessage(response);
    }
  }
}
