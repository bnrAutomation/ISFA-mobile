import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/my_activity_module/model/my_activity_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

class MyActivityRepository {
  final int userId;

  MyActivityRepository(int? forUserId)
      : userId = forUserId ?? AppStorage().userDetail!.id;

  Future<List<MyActivityDataList>> getMyActivity({
    required DateTime dateTime,
  }) async {
    final response = await CustomHttpBaseClient().get(Uri.parse(
        '${URLConstants.activities}/$userId/${dateTime.toStringFormat('yyyy-MM-dd')}'));
    return response.body.isEmpty
        ? <MyActivityDataList>[]
        : MyActivityModel.fromRawJson(response.body).dataList;
  }
}
