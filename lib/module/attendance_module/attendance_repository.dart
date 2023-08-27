import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'model/attendance_model.dart';

class AttendanceRepository {
  final int userId;
  final client = CustomHttpBaseClient();
  AttendanceRepository(int? forUserId)
      : userId = forUserId ?? AppStorage().userDetail!.id;

  Future<List<AttendanceData>> getUserAttendance({
    required DateTime dateTime,
  }) async {
    final response = await client.get(Uri.parse(
        '${URLConstants.attendence}/$userId/${dateTime.toStringFormat('yyyy')}/${dateTime.toStringFormat('MM')}'));
    return response.body.isEmpty
        ? <AttendanceData>[]
        : AttendanceModel.fromRawJson(response.body).data;
  }
}
