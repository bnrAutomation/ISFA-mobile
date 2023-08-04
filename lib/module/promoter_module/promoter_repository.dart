import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:image_picker/image_picker.dart';

class PromoterRepository {
  final userId = AppStorage().userDetail!.id;
  final companyId = AppStorage().homeInfo!.userInfo.companyId;
  Future<PromoterStoreDetailModel> getStoreDetails() async {
    final response = await get(
        Uri.parse('${URLConstants.promoterStoreDetail}/$userId/$companyId'));
    final resJson = json.decode(response.body);
    if (response.statusCode == 200 && resJson['data'] is Map) {
      return PromoterStoreDetailModel.fromJson(resJson['data']);
    } else {
      throw resJson['message'];
    }
  }

  Future<InventoryDetailModel> getInventoryDetail(int storeId) async {
    final response = await get(
        Uri.parse('${URLConstants.getInventory}/$userId/$companyId/$storeId'));
    final resJson = json.decode(response.body);
    if (response.statusCode == 200 && resJson['data'] is Map) {
      return InventoryDetailModel.fromJson(resJson['data']);
    } else {
      throw resJson['message'];
    }
  }

  Future<String> markInOutStore(XFile file, double latitude, double longitude,
      int storeId, bool isIn) async {
    final url = Uri.parse(isIn ? URLConstants.markin : URLConstants.markOut);
    final request = MultipartRequest('POST', url);
    request.files.add(await MultipartFile.fromPath('file', file.path));
    request.fields.addAll({
      "userId": userId.toString(),
      "storeId": storeId.toString(),
      "status": isIn.toString(),
      "campaignId": companyId.toString()

      // "pjpId": "122"
    });
    if (isIn) {
      request.fields.addAll({
        "inLatitude": latitude.toString(),
        "inLongitude": longitude.toString(),
      });
    } else {
      request.fields.addAll({
        "outLatitude": latitude.toString(),
        "outLongitude": longitude.toString(),
      });
    }

    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      return json.decode(body)['message'] ?? "";
    } else {
      throw body.isEmpty
          ? "Something went wrong"
          : json.decode(body)['message'] ?? "Something went wrong";
    }
  }

  Future<List<CampaignDetailModel>> getCompaignList(int storeId) async {
    final response =
        await get(Uri.parse("${URLConstants.getCompaingns}/$storeId"));

    if (response.statusCode == 200) {
      return UserCampaignsModel.fromRawJson(response.body).dataList ?? [];
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
