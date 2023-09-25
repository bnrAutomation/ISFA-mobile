import 'dart:convert';

import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';
import 'package:i_densfa/module/campaign_module/new_models/question_section.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class CampaignRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  final client = CustomHttpBaseClient();
  Future<List<AllCampaignModel>> getCampaignsForStore() async {
    final response = await client.get(Uri.parse(URLConstants.getAllCampaigns));

    if (response.statusCode == 200) {
      List<AllCampaignModel> alllist = (json.decode(response.body) as List)
          .map((e) => AllCampaignModel.fromJson(e))
          .toList();

      List<AllCampaignModel> publishList = [];
      publishList
          .addAll(alllist.where((element) => element.status == "PUBLISHED"));
      return publishList;
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<List<CampaignQuestionSectionModel>> getSections(
      {required String campaignUuid}) async {
    final response = await client.get(
        Uri.parse("${URLConstants.getAllCampaigns}/$campaignUuid/section"));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => CampaignQuestionSectionModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<List<CampaignQuestionModel>> getQuestions(
      {required String campaignUuid, required String sectionUuid}) async {
    final response = await client.get(Uri.parse(
        "${URLConstants.getAllCampaigns}/$campaignUuid/section/$sectionUuid/question"));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => CampaignQuestionModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<bool> saveCampaignAnswers(Map<String, dynamic> bodyMap) async {
    final response = await client.post(
      Uri.parse(
          "${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/client/campaign/${bodyMap['campaignUuid']}/response"),
      body: jsonEncode(bodyMap),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<SavedCampaignDataModel?> savedCampaignResponse(
      String campaignUuid) async {
    final response = await client.get(Uri.parse(
        "${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId/campaign/$campaignUuid?filterBy=date&unit=120"));

    if (response.statusCode == 200) {
      final dataJson = jsonDecode(response.body);
      if (dataJson == null) {
        throw getErrorMessage(response.body);
      } else {
        return SavedCampaignDataModel.fromJson(dataJson);
      }
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
