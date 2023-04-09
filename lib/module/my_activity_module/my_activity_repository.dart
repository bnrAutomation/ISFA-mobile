import 'package:http/http.dart';
import 'package:i_densfa/module/my_activity_module/model/my_activity_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

class MyActivityRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;

  ///1684/2021-08'
  Future<List<AttendanceData>> getMyActivity({
    required DateTime dateTime,
  }) async {
    final response = await get(Uri.parse(
        '${URLConstants.attendence}/$userId/${dateTime.toStringFormat('yyyy-MM')}'));
    return response.body.isEmpty
        ? <AttendanceData>[]
        : MyActivityModel.fromRawJson(response.body).data.attendanceData;
  }
}
