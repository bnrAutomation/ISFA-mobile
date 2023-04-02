import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

class PromoterRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  Future<PromoterStoreDetailModel> getStoreDetails() async {
    final response = await get(
        Uri.parse('${URLConstants.promoterStoreDetail}/$userId/$compId'));
    final resJson = json.decode(response.body);
    if (response.statusCode == 200 && resJson['data'] is Map) {
      return PromoterStoreDetailModel.fromJson(resJson['data']);
    } else {
      throw resJson['message'];
    }
  }

  Future<InventoryDetailModel> getInventoryDetail(int storeId) async {
    final response = await get(
        Uri.parse('${URLConstants.getInventory}/$userId/$compId/$storeId'));
    final resJson = json.decode(response.body);
    if (response.statusCode == 200 && resJson['data'] is Map) {
      return InventoryDetailModel.fromJson(resJson['data']);
    } else {
      throw resJson['message'];
    }
  }
}
