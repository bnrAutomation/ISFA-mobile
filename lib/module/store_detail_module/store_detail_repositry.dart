import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/promoter_module/models/compaigns_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class StoreDetailRepository {
  Future<List<CompaignsModel>> getCompaignList(int storeId) async {
    final response =
        await get(Uri.parse('${URLConstants.getCompaingns}/$storeId'));

    if (response.statusCode == 200) {
      final resJson = json.decode(response.body);
      if (resJson['dataList'] is List) {
        return (resJson['dataList'] as List)
            .map((e) => CompaignsModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else {
      final resJson = json.decode(response.body);
      throw resJson['message'];
    }
  }
}
