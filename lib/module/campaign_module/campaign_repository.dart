import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';
import 'package:i_densfa/module/campaign_module/new_models/question_section.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class CampaignRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;

  Future<List<AllCampaignModel>> getCampaignsForStore() async {
    final response = await get(Uri.parse(URLConstants.getAllCampaigns));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => AllCampaignModel.fromJson(e))
          .toList();
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<List<CampaignQuestionSectionModel>> getSections(
      {required String campaignUuid}) async {
    final response = await get(Uri.parse(
        "${URLConstants.getCampaignQuestions}/$campaignUuid/section"));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => CampaignQuestionSectionModel.fromJson(e))
          .toList();
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<List<CampaignQuestionModel>> getQuestions(
      {required String campaignUuid, required String sectionUuid}) async {
    final response = await get(Uri.parse(
        "${URLConstants.getCampaignQuestions}/$campaignUuid/section/$sectionUuid/question"));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => CampaignQuestionModel.fromJson(e))
          .toList();
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
      // "storeId": storeId
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

  Future<SavedCampaignDataModel?> savedCampaignResponse(
      String campaignId) async {
    final response = await get(
        Uri.parse('${URLConstants.savedCampaignResponse}/$userId/$campaignId'));

    if (response.statusCode == 200) {
      final dataJson = jsonDecode(response.body)['data'];
      if (dataJson == null) {
        throw response.body.isEmpty
            ? "Something went wrong"
            : jsonDecode(response.body)['message'] ?? "Something went wrong";
      } else {
        return SavedCampaignDataModel.fromJson(dataJson);
      }
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }
}
