import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/learner_module/learner/model/learner_model.dart';
import 'package:i_densfa/utility/app_constants.dart';

class LearnerRepository {
  final client = CustomHttpBaseClient();
  Future<LearnerModel> getLearner() async {
    final response = await client.get(Uri.parse(URLConstants.learnerContent));

    if (response.statusCode == 200) {
      return LearnerModel.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
