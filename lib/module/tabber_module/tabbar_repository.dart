import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class TabbarRepository {
  final userId = AppStorage().userDetail!.id;
  Future<SideMenuModel> getSideMenuDetails() async {
    final userId = AppStorage().userDetail!.id;
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

  Future<bool> endDuty(double latitude, double longitude) async {
    final reqBody = {
      "userId": userId.toString(),
      "status": "false",
      "outLatitude": latitude.toString(),
      "outLongitude": longitude.toString(),
    };

    final response = await post(Uri.parse(URLConstants.endDuty),
        body: jsonEncode(reqBody),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : json.decode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<bool> startDuty(XFile file, double latitude, double longitude) async {
    final url = Uri.parse(URLConstants.startDuty);
    final request = MultipartRequest('POST', url);

    final fileStream = ByteStream(file.openRead());
    final fileLength = await file.length();

    final multipartFile = MultipartFile(
      'image',
      fileStream,
      fileLength,
      filename: basename(file.path),
    );

    request.files.add(multipartFile);
    request.fields.addAll({
      "userId": userId.toString(),
      "status": "true",
      "inLatitude": latitude.toString(),
      "inLongitude": longitude.toString(),
    });

    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      return true;
    } else {
      throw body.isEmpty
          ? "Something went wrong"
          : json.decode(body)['message'] ?? "Something went wrong";
    }
  }
}
