import 'dart:convert';

import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

import 'assessment_model.dart';

class AssessmentRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  final client = CustomHttpBaseClient();
  Future<List<AssessmentDetailModel>> getAssessmentForUser() async {
    final response = await client
        .get(Uri.parse("${URLConstants.getAssessmentListByUserId}/$userId"));

    if (response.statusCode == 200) {
      return UserAssessmentsModel.fromRawJson(response.body).dataList ?? [];
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<List<AssessQuestionModel>> getQuestions(int id) async {
    final response = await client
        .get(Uri.parse("${URLConstants.getAssessmentQuestions}/$compId/$id"));

    if (response.statusCode == 200) {
      final body = AssessmentQuestionsModel.fromRawJson(response.body);
      return body.data?.questionData ?? [];
    } else {
      throw getErrorMessage(response.body);
    }
  }

  Future<AssessmentScoreModel> saveAssessmentAnswers(
      List<Map<String, dynamic>> answers, int timeTook) async {
    final bodyMap = {
      "answerData": answers,
      "assessmentCompletionTime": timeTook,
      "assessmentId": answers.first['assessmentId']
    };
    final response = await client.post(
      Uri.parse("${URLConstants.saveAssessmentAnswers}/$userId"),
      body: jsonEncode(bodyMap),
      headers: {'Content-Type': 'application/json'},
    );
    final jsonBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonBody["data"] is Map) {
        return AssessmentScoreModel.fromJson(jsonBody["data"]);
      } else {
        throw jsonBody['message'];
      }
    } else {
      throw getErrorMessage(response.body);
    }
  }
}
