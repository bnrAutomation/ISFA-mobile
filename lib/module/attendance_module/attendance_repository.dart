import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'model/attendance_model.dart';

class AttendanceRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;

  ///1684/2021-08'
  Future<List<AttendanceData>> getMyActivity({
    required DateTime dateTime,
  }) async {
    final response = await get(Uri.parse(
        '${URLConstants.attendence}/$userId/${dateTime.toStringFormat('yyyy')}/${dateTime.toStringFormat('MM')}'));
    return response.body.isEmpty
        ? <AttendanceData>[]
        : AttendanceModel.fromRawJson(response.body).data;
  }
}
