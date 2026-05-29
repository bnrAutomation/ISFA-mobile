import 'dart:convert';

import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/filled_campaign_list.dart';
import 'package:i_densfa/module/my_schedule_module/beat_plan_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/services/my_store_offline_service.dart';

class MyStoreRepository {
  final int companyId = AppStorage().homeInfo!.userInfo.companyId;
  final int userId;

  final httpClient = CustomHttpBaseClient.instance;
  final MyStoreOfflineService _offlineService = MyStoreOfflineService();

  MyStoreRepository(int? forUserId)
      : userId = forUserId ?? AppStorage().userDetail!.id;


  Future<List<BeatPlanModel>> getBeatPlans(
      Map<String, String> queryParameters) async {
    // Decide online/offline using connectivity.
    final isOnline = await _offlineService.isOnline();

    if (!isOnline) {
      // Offline: try to return cached beat plans.
      final cached = await _offlineService.getCachedBeatPlans();
      if (cached != null) {
        return cached;
      }
      // No cache – return empty list so UI can still render gracefully.
      return [];
    }

    // Online: fetch from API and cache for offline use.
    final response = await httpClient.post(
      Uri.parse(URLConstants.beatPlans),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "date": DateTime.now().toStringFormat("yyyy-MM-dd"),
        "userId": userId,
        "companyId": companyId,
      }),
    );

    if (response.statusCode == 200) {
      final dataResponse = json.decode(response.body)["data"];
      final List plans = dataResponse is List ? dataResponse : [];
      if (plans.isNotEmpty) {
        final result =
            plans.map((e) => BeatPlanModel.fromJson(e)).toList();
        // Cache result for offline usage.
        await _offlineService.cacheBeatPlans(result);
        return result;
      } else {
        throw getErrorMessage(response);
      }
    } else {
      throw getErrorMessage(response);
    }
  }

   Future<List<AllCampaignModel>> getCampaignsForStore(String storeId) async {
    final uri = Uri.parse(URLConstants.getAllCampaigns).replace(
        queryParameters: {'userId': userId.toString(), "storeId": storeId});
    final response = await httpClient.get(uri);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => AllCampaignModel.fromJson(e))
          .where((element) => element.status == "PUBLISHED")
          .where((element) => !element.isNegative())
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getFilledCampaign(int storeId) async {
    final response = await httpClient.get(
      Uri.parse(URLConstants.getAllClientCampaigns).replace(queryParameters: {
        'userId': userId.toString(),
        "storeId": storeId.toString()
      }),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${AppStorage().authToken}",
      },
    );
    if (response.statusCode == 200) {
      return FilledCampaignList.fromRawJson(response.body)
          .userCampaignResponses;
    } else {
      throw getErrorMessage(response);
    }
  }
}