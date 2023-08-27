import 'dart:convert';

import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'models/team_data_model.dart';
import 'models/team_list_model.dart';

class TeamRepository {
  final userId = AppStorage().userDetail!.id;
  final client = CustomHttpBaseClient();
  Future<TeamListResponse> getTeamMembers(int? forUserId) async {
    final id = forUserId ?? userId;
    final response =
        await client.get(Uri.parse('${URLConstants.getTeamMembers}/$id'));
    if (response.statusCode == 200) {
      final responseBody = TeamListResponse.fromRawJson(response.body);
      if (responseBody.dataList.isEmpty) {
        throw responseBody.message;
      } else {
        return responseBody;
      }
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<TeamDataModel> teamData() async {
    final date = DateTime.now().toStringFormat('yyyy-MM-dd');
    final response = await client.post(
        Uri.parse('${URLConstants.getTeamData}/$userId'),
        body: jsonEncode({"fromDate": date, "toDate": date}),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json"
        });
    if (response.statusCode == 200) {
      return TeamDataResponse.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<String> sendNotification(
      {required title,
      required String message,
      required List<int> userIds,
      required int leadUserId}) async {
    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json'
    };

    final data =
        jsonEncode({"message": message, "title": title, "userIds": userIds});

    final url = Uri.parse('${URLConstants.teamNotification}/$leadUserId');

    final res = await client.post(url, headers: headers, body: data);
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['message'];
    } else {
      throw getErrorMessage(res.body);
    }
  }
}
