import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class TabbarRepository {
  final userId = AppStorage().userDetail!.id;
  final companyId = AppStorage().userDetail!.companyId;
  Future<SideMenuModel> getSideMenuDetails() async {
    final response =
        await get(Uri.parse('${URLConstants.sidemenuDetails}/$userId'));
    final jsonRec = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return SideMenuModel.fromJson(jsonRec['data']);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }

    // final r = jsonEncode({
    //   "user_info": {
    //     "phone_no": null,
    //     "role": null,
    //     "user_name": "shubhamj@denave.com",
    //     "email": "shubhamj@denave.com"
    //   },
    //   "menu": [
    //     {
    //       "name": "Attendance",
    //       "icon": "https://example.com/icon_image/attendance.png",
    //       "isActive": true,
    //       "key": "attendance"
    //     },
    //     {
    //       "name": "Leave",
    //       "icon": "https://example.com/icon_image/leave.png",
    //       "isActive": true,
    //       "key": "leave"
    //     },
    //     {
    //       "name": "Promoter",
    //       "icon": "https://example.com/icon_image/promoter.png",
    //       "isActive": true,
    //       "key": "promoter"
    //     }
    //   ]
    // });

    // return SideMenuModel.fromRawJson(r);
  }

  Future<String> startEndDuty(
      XFile file, double latitude, double longitude, bool isStart) async {
    final url =
        Uri.parse(isStart ? URLConstants.startDuty : URLConstants.endDuty);
    final request = MultipartRequest('POST', url);

    final fileStream = ByteStream(file.openRead());
    final fileLength = await file.length();

    final multipartFile = MultipartFile(
      'file',
      fileStream,
      fileLength,
      filename: basename(file.path),
    );

    request.files.add(multipartFile);
    request.fields.addAll({
      "userId": userId.toString(),
      "status": isStart.toString(),
      "campaignId": companyId.toString()
    });

    if (isStart) {
      request.fields.addAll({
        "inLatitude": latitude.toString(),
        "inLongitude": longitude.toString(),
      });
    } else {
      request.fields.addAll({
        "outLatitude": latitude.toString(),
        "outLongitude": longitude.toString(),
      });
    }

    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      return json.decode(body)['message'] ?? "";
    } else {
      throw body.isEmpty
          ? "Something went wrong"
          : json.decode(body)['message'] ?? "Something went wrong";
    }
  }
}
