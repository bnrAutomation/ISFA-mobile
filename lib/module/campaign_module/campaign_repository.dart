import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class CampaignRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  final int storeId;

  CampaignRepository(this.storeId);
  Future<List<CampaignDetailModel>> getCampaignsForStore() async {
    final response =
        await get(Uri.parse("${URLConstants.getCampaignListByUserId}/$userId"));

    if (response.statusCode == 200) {
      return UserCampaignsModel.fromRawJson(response.body).dataList ?? [];
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<List<CampQuestionModel>> getQuestions(int id) async {
    final response = await get(
        Uri.parse("${URLConstants.getCampaignQuestions}/$compId/$id"));

    if (response.statusCode == 200) {
      final body = CampaignQuestionsModel.fromRawJson(response.body);
      return body.data?.questionData ?? [];
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<bool> saveCampaignAnswers(List<Map<String, dynamic>> answers) async {
    if (answers.isEmpty) {
      return false;
    }

    final bodyMap = {
      "answerData": answers,
      "campaignId": answers.first['campaignId'],
      "storeId": storeId
    };
    final response = await post(
      Uri.parse("${URLConstants.saveCampaignAnswers}/$userId"),
      body: jsonEncode(bodyMap),
      headers: {'Content-Type': 'application/json'},
    );
    final jsonBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonBody['message'] ?? "Something went wrong";
    }
  }

  Future<SavedCampaignDataModel?> savedCampaignResponse(int campaignId) async {
    final response = await get(
        Uri.parse('${URLConstants.savedCampaignResponse}/$userId/$campaignId'));

    if (response.statusCode == 200) {
      final dataJson = jsonDecode(response.body)['data'];
      if (dataJson == null) return null;
      return SavedCampaignDataModel.fromJson(dataJson);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }
}
