import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class PromoterRepository {
  final userId = 1;
  final compId = 1;
  final storeId = 1;
  Future<PromoterStoreDetailModel> getStoreDetails() async {
    final response = await get(
        Uri.parse('${URLConstants.promoterStoreDetail}/$userId/$compId'));
    if (response.statusCode == 200) {
      return PromoterStoreDetailModel.fromJson(
          json.decode(response.body)['data']);
    } else {
      throw json.decode(response.body)['message'];
    }
  }

  Future<InventoryDetailModel> getInventoryDetail() async {
    final response = await get(
        Uri.parse('${URLConstants.getInventory}/$userId/$compId/$storeId'));
    if (response.statusCode == 200) {
      return InventoryDetailModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw json.decode(response.body)['message'];
    }
  }
}
