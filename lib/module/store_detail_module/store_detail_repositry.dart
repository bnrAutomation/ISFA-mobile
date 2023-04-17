import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class StoreDetailRepository {
  Future<List<CampaignDetailModel>> getCompaignList(int storeId) async {
    final response =
        await get(Uri.parse("${URLConstants.getCompaingns}/$storeId"));

    if (response.statusCode == 200) {
      return UserCampaignsModel.fromRawJson(response.body).dataList ?? [];
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<String> markInOutStore(
      {required XFile file,
      required double latitude,
      required double longitude,
      required int pjpId,
      required int storeId,
      required bool isIn}) async {
    final url = Uri.parse(isIn ? URLConstants.markin : URLConstants.markOut);
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
    final userId = AppStorage().userDetail!.id;
    final companyId = AppStorage().userDetail!.companyId;
    request.fields.addAll({
      "userId": userId.toString(),
      "storeId": storeId.toString(),
      "status": isIn.toString(),
      "pjpId": pjpId.toString(),
      "campaignId": companyId.toString()
    });
    if (isIn) {
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
