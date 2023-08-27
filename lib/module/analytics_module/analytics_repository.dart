import 'dart:convert';

import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

import 'model/analytics_model.dart';

class AnalyticsRepository {
  final int userId;
  final client = CustomHttpBaseClient();
  AnalyticsRepository(int? forUserId)
      : userId = forUserId ?? AppStorage().userDetail!.id;
  Future<List<AnalyticsModel>> getDetails({required int days}) async {
    final url = Uri.parse(
        '${URLConstants.baseURLStart}/campaign-service/iSFA/api/v1/analytics/$userId?filterBy=date&unit=$days');

    final res = await client.get(url);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => AnalyticsModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(res.body);
    }
  }
}
