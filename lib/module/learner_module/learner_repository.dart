import 'package:http/http.dart';
import 'package:i_densfa/module/learner_module/learner/model/learner_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/handler.dart';

class LearnerRepository {
  Future<LearnerModel> getLearner() async {
    final response = await get(
      Uri.parse(URLConstants.learnerContent),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${AppStorage().authToken}",
      },
    );

    if (response.statusCode == 200) {
      return LearnerModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }
}
