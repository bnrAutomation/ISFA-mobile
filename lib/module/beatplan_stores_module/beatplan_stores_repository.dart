import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'beat_plan_model.dart';

class BeatPlanStoresRepository {
  final int companyId;
  final userId = AppStorage().userDetail!.id;

  BeatPlanStoresRepository(this.companyId);

  Future<List<BeatPlanModel>> getBeatPlans(DateTime date) async {
    final response = await post(Uri.parse(URLConstants.beatPlans),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "date": date.toStringFormat("yyyy-MM-dd"),
          "userId": userId,
          "companyId": companyId
        }));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)["data"];
      return data.map((e) => BeatPlanModel.fromJson(e)).toList();
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }
}
