import 'package:http/http.dart';
import 'package:i_densfa/module/leaves_module/model/leave_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class LeaveRepository {
  Future<EmpLeaveDetailsModel> getDetails() async {
    const empId = 3;
    const companyId = 4;
    final response =
        await get(Uri.parse('${URLConstants.leaveDetails}/$empId/$companyId'));
    if (response.statusCode == 200) {
      return EmpLeaveDetailsModel.fromRawJson(response.body);
    } else {
      throw response.statusCode;
    }
  }
}
