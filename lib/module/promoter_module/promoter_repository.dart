import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class PromoterRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  Future<PromoterStoreDetailModel> getStoreDetails() async {
    final response = await get(
        Uri.parse('${URLConstants.promoterStoreDetail}/$userId/$compId'));
    final resJson = json.decode(response.body);
    if (response.statusCode == 200 && resJson['data'] is Map) {
      return PromoterStoreDetailModel.fromJson(resJson['data']);
    } else {
      throw resJson['message'];
    }
  }

  Future<InventoryDetailModel> getInventoryDetail(int storeId) async {
    final response = await get(
        Uri.parse('${URLConstants.getInventory}/$userId/$compId/$storeId'));
    final resJson = json.decode(response.body);
    if (response.statusCode == 200 && resJson['data'] is Map) {
      return InventoryDetailModel.fromJson(resJson['data']);
    } else {
      throw resJson['message'];
    }
  }

  Future<bool> markOutStore(
      double latitude, double longitude, int storeId) async {
    final reqBody = {
      "userId": userId.toString(),
      "storeId": storeId.toString(),
      "status": "false",
      "outLatitude": latitude.toString(),
      "outLongitude": longitude.toString(),
      // "pjpId": "122"
    };

    final response = await post(Uri.parse(URLConstants.markOut),
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

  Future<bool> markInStore(
      XFile file, double latitude, double longitude, int storeId) async {
    final url = Uri.parse(URLConstants.markin);
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
      "storeId": storeId.toString(),
      "status": "true",
      "inLatitude": latitude.toString(),
      "inLongitude": longitude.toString(),
      // "pjpId": "122"
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
