import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/promoter_module/feedback/model/feedback_model.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';

class StoreDetailRepository {
  final userId = AppStorage().userDetail!.id;
  final client = CustomHttpBaseClient();
  Future<GetStoreDetailDataModel> getStoreDetails(int storeId) async {
    final response = await client.get(
      Uri.parse("${URLConstants.getStoreDetail}/$userId/$storeId"),
    );

    if (response.statusCode == 200) {
      final dataJson = jsonDecode(response.body)['data'];
      if (dataJson == null) {
        throw 'No store found';
      }
      return GetStoreDetailDataModel.fromJson(dataJson);
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<bool> addNoteForStore(String note, int storeId) async {
    final requestBody = {"note": note, "storeId": storeId, "userId": userId};

    final response = await client.post(Uri.parse(URLConstants.addNote),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<List<FeedbackDataList>> getFeedback(String storeName) async {
    final requestBody = {
      "storeName": storeName,
      "createdBy": AppStorage().userDetail!.id
    };

    final response =
        await client.post(Uri.parse(URLConstants.getFeedbackByUserIdAndStore),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": "Bearer ${AppStorage().authToken}",
            },
            body: json.encode(requestBody));

    if (response.statusCode == 201 || response.statusCode == 200) {
      debugPrint(response.body);
      return FeedbackModel.fromJson(jsonDecode(response.body)).dataList;
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<bool> deleteNoteForStore(int noteId) async {
    final response = await client.delete(
      Uri.parse('${URLConstants.deleteNote}/$noteId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response.body);
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
    request.headers.addAll({
      'Authorization': 'Bearer ${AppStorage().authToken}',
    });
    final multipartFile = await MultipartFile.fromPath('file', file.path);
    request.files.add(multipartFile);

    request.fields.addAll({
      "userId": userId.toString(),
      "storeId": storeId.toString(),
      "status": isIn.toString(),
      "pjpId": pjpId.toString(),
      "campaignId": AppStorage().userDetail!.companyId.toString()
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
