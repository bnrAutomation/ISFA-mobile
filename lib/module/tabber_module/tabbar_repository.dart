import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:image_picker/image_picker.dart';

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
      throw getErrorMessage(response.body);
    }
  }

  Future<String> startEndDuty(
      XFile file, double latitude, double longitude, bool isStart) async {
    final url =
        Uri.parse(isStart ? URLConstants.startDuty : URLConstants.endDuty);
    final request = MultipartRequest('POST', url);

    final multipartFile = await MultipartFile.fromPath('file', file.path);

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
