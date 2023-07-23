import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/beatplan_stores_module/store_list_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'beat_plan_model.dart';

class BeatPlanStoresRepository {
  final int companyId;
  final userId = AppStorage().userDetail!.id;

  BeatPlanStoresRepository(this.companyId);

  Future<List<BeatPlanModel>> getBeatPlans(DateTime date) async {
    // {"date":"2023-04-09","userId":1,"companyId":33}
    final response = await post(Uri.parse(URLConstants.beatPlans),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "date": date.toStringFormat("yyyy-MM-dd"),
          "userId": userId,
          "companyId": companyId
        }));

    if (response.statusCode == 200) {
      final dataResponse = json.decode(response.body)["data"];
      final List plans = dataResponse is List ? dataResponse : [];
      if (plans.isNotEmpty) {
        return plans.map((e) => BeatPlanModel.fromJson(e)).toList();
      } else {
        throw response.body.isEmpty
            ? "Something went wrong"
            : json.decode(response.body)['message'] ?? "Something went wrong";
      }
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<List<StoreItemModel>> getStores() async {
    final response =
        await get(Uri.parse('${URLConstants.getStores}/$companyId'));

    if (response.statusCode == 200) {
      final dataList = json.decode(response.body)["dataList"];
      final List stores = dataList is List ? dataList : [];
      if (stores.isNotEmpty) {
        return stores.map((x) => StoreItemModel.fromJson(x)).toList();
      } else {
        throw response.body.isEmpty
            ? "Something went wrong"
            : json.decode(response.body)['message'] ?? "Something went wrong";
      }
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<bool> beatPlanUpload(DateTime date, String reason, int storeId) async {
    final response = await post(Uri.parse(URLConstants.beatPlanUpload),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "companyId": companyId,
          "pjpDate": date.toStringFormat("yyyy-MM-dd"),
          "remarks": reason,
          "storeId": storeId,
          "userId": userId,
          "createdBy": AppStorage().userDetail!.roles,
          "active": "true"
        }));
    if (response.statusCode != 200) {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    } else {
      return true;
    }
  }
}
