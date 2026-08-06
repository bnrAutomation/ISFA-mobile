import 'dart:convert';

import 'package:i_densfa/module/issues_management_module/issues_list_module/model/issues_ticket_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/handler.dart';

class IssuesManagementDetailRepository {
  final userId = AppStorage().userDetail?.id ?? 0;
  final companyId = AppStorage().userDetail?.companyId;
  final client = CustomHttpBaseClient.instance;

  Future<IssuesTicketModel> getTicketDetails(String ticketId) async {
    final response =
        await client.get(Uri.parse("${URLConstants.getTicket}/$ticketId"));
    if (response.statusCode == 200) {
      return IssuesTicketModel.fromJson(json.decode(response.body));
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> submitTicketDetails(
      String ticketId,
      String status,
      String? afterImage,
      String? reopenBeforeImage,
      String? reopenAfterImage) async {
    final body = {
      "status": status,
      "afterImage": afterImage,
      "userId": userId,
      "hasReopen": status == 'Re-Open',
      "reopenBeforeImage": reopenBeforeImage,
      "reopenAfterImage": reopenAfterImage
    };
    final response = await client.put(
        Uri.parse("${URLConstants.getTicket}/$ticketId"),
        body: jsonEncode(body));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> acceptIssues(Map<String, Object> body) async {
    final response = await client.put(
        Uri.parse("${URLConstants.getTicket}/update-status"),
        body: jsonEncode(body));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }
}
