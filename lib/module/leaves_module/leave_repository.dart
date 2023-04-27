import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/leaves_module/model/leave_enums.dart';
import 'package:i_densfa/module/leaves_module/model/leave_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'model/leave_type_model.dart';

class LeaveRepository {
  final empId = AppStorage().userDetail!.id;
  final companyId = AppStorage().homeInfo!.userInfo.companyId;

  Future<EmpLeaveDetailsModel> getDetails() async {
    final response =
        await get(Uri.parse('${URLConstants.leaveDetails}/$empId/$companyId'));
    if (response.statusCode == 200) {
      return EmpLeaveDetailsModel.fromRawJson(response.body);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<bool> applyLeave(
      {required int leaveTypeId,
      required int dayId,
      required DateTime fromDate,
      required DateTime toDate,
      required String reason}) async {
    final body = {
      "companyId": companyId,
      "userId": empId,
      "leaveId": leaveTypeId,
      "dayId": dayId,
      "leaveStatus": LeaveStatus.pending.toStr(),
      "dateFrom": fromDate.toStringFormat('yyyy-MM-dd'),
      "dateTo": toDate.toStringFormat('yyyy-MM-dd'),
      "reason": reason,
    };
    final response = await post(Uri.parse(URLConstants.applyLeave),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<bool> leaveAction(bool isApproved, int id) async {
    final body = {
      "leaveStatus": isApproved
          ? LeaveStatus.approved.toStr()
          : LeaveStatus.rejected.toStr(),
      "leaveRequestId": id
    };

    final response = await put(Uri.parse('${URLConstants.leaveRequest}/$empId'),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    final response = await get(Uri.parse(URLConstants.leaves));
    return leaveTypeListfromBody(response.body);
  }
}
