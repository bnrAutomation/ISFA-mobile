import 'dart:convert';

import 'package:i_densfa/module/issues_management_module/issues_list_module/model/issues_ticket_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/handler.dart';

class IssuesManagementRepository {
  final client = CustomHttpBaseClient.instance;
  final companyId = AppStorage().userDetail?.companyId ?? 0;
  final userId = AppStorage().userDetail?.id ?? 0;

  Future<IssuesTicketModelContent> getIssuesManagementList(
      DateTime startDate, DateTime endDate, int pageOffset) async {
    Map<String, String> param = {
      "page": pageOffset.toString(),
      "size": 15.toString(),
      "sortBy": "ticketDate",
      "order": "desc",
      "fromDate": startDate.toStringFormat("yyyy-MM-dd"),
      "toDate": endDate.toStringFormat("yyyy-MM-dd")
    };
    final response = await client.get(
        Uri.parse(URLConstants.allTickets).replace(queryParameters: param));
    if (response.statusCode == 200) {
      return IssuesTicketModelContent.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<IssuesTicketModel> getTicketDetails(int ticketId) async {
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

  Future<IssuesTicketModelContent> getIssuesManagementListByParm(
      Map<String, String> param) async {
    final response = await client.get(
        Uri.parse(URLConstants.filterTickets).replace(queryParameters: param));
    if (response.statusCode == 200) {
      return IssuesTicketModelContent.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }
}
