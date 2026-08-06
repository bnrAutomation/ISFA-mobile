import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'feedback_model.dart';

class FeedbackRepository {
  final userId = AppStorage().userDetail!.id;
  final companyId = AppStorage().userDetail!.companyId;
  final client = CustomHttpBaseClient.instance;
  Future<List<FeedbackPorposeModel>> getFeedbackPurposes() async {
    final response =
        await client.get(Uri.parse(URLConstants.getFeedbackPurposes));
    if (response.statusCode == 200) {
      final List list = json.decode(response.body)['dataList'];
      return List.from(list.map((x) => FeedbackPorposeModel.fromJson(x)));
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> saveFeedback(
      XFile? file, int purposeId, String remark, String storeName) async {
    final url = Uri.parse("${URLConstants.createFeedback}/$userId");
    final request = MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer ${AppStorage().authToken}',
    });
    request.fields.addAll({
      'userId': userId.toString(),
      'reason': remark,
      'purposeId': purposeId.toString(),
      "storeName": storeName,
      "companyId": companyId.toString(),
      "activity": "feedback"
    });
    if (file != null) {
      XFile? filePath = (await compressImage(file));
      if(filePath!=null){
      final multipartFile = await MultipartFile.fromPath('image', filePath.path);
      request.files.add(multipartFile);
      }
    }

    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      return true;
    } else {
      final bod = jsonDecode(body);
      final String mess = bod['message'] ?? bod["error"];
      throw mess;
      //throw getErrorMessage(body);
    }
  }


   Future<XFile?> compressImage(XFile file,
      {int? reduceSize}) async {
    String name = "feedback";
    final directory =
        "${await _getExternalStoragePath()}/${AppStorage().userDetail?.id}_${name}_${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}";

    int size = reduceSize ?? 90;
    final img = await FlutterImageCompress.compressAndGetFile(
      file.path,
      directory,
      quality: size,
    );
    final listImg = await img?.readAsBytes();
    // checking if file size if more than 1000 Kb then further reduce it
    if ((listImg?.lengthInBytes ?? 0) / 1024.0 > 400) {
      return await compressImage(file, reduceSize: size - 10);
    }
    return img;
  }

  Future<String> _getExternalStoragePath() async {
    if (Platform.isIOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getExternalStorageDirectory())?.path ?? "";
    }
  }
}
