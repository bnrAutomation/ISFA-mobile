import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'feedback_model.dart';

class FeedbackRepository {
  final userId = AppStorage().userDetail!.id;
  final companyId = AppStorage().userDetail!.companyId;
  final client = CustomHttpBaseClient();
  Future<List<FeedbackPorposeModel>> getFeedbackPurposes() async {
    final response =
        await client.get(Uri.parse(URLConstants.getFeedbackPurposes));
    if (response.statusCode == 200) {
      final List list = json.decode(response.body)['dataList'];
      return List.from(list.map((x) => FeedbackPorposeModel.fromJson(x)));
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<bool> saveFeedback(
      XFile file, int purposeId, String remark, String storeName) async {
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
    });

    final multipartFile = await MultipartFile.fromPath('image', file.path);
    request.files.add(multipartFile);

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
