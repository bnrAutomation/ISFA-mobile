import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/handler.dart';

import 'models/team_data_model.dart';
import 'models/team_list_model.dart';

class TeamRepository {
  final userId = AppStorage().userDetail!.id;
  Future<List<TeamMemberModel>> getTeamMembers(int? forUserId) async {
    final id = forUserId ?? userId;
    final response = await get(Uri.parse('${URLConstants.getTeamMembers}/$id'));
    if (response.statusCode == 200) {
      final responseBody = TeamListResponse.fromRawJson(response.body);
      final list = responseBody.dataList;
      if (list.isEmpty) {
        throw responseBody.message;
      } else {
        return list;
      }
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<TeamDataModel> teamData() async {
    final date = DateTime.now().toStringFormat('yyyy-MM-dd');
    final response = await post(
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
}
