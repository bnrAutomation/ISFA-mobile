import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/module/learner_module/learner/model/learner_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class LearnerRepository {
  Future<LearnerModel> getLearner() async {
    final response = await get(Uri.parse(URLConstants.learnerContent));

    if (response.statusCode == 200) {
      return LearnerModel.fromRawJson(response.body);
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }
}
