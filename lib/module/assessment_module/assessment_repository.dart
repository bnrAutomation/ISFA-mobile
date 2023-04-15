import 'dart:convert';

import 'package:http/http.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';

import 'assessment_model.dart';

class AssessmentRepository {
  final userId = AppStorage().userDetail!.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  Future<List<AssessmentDetailModel>> getAssessmentForUser() async {
    final response = await get(
        Uri.parse("${URLConstants.getAssessmentListByUserId}/$userId"));

    if (response.statusCode == 200) {
      return UserAssessmentsModel.fromRawJson(response.body).dataList ?? [];
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<List<AssessQuestionModel>> getQuestions(int id) async {
    final response = await get(
        Uri.parse("${URLConstants.getAssessmentQuestions}/$compId/$id"));

    if (response.statusCode == 200) {
      final body = AssessmentQuestionsModel.fromRawJson(response.body);
      return body.data?.questionData ?? [];
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonDecode(response.body)['message'] ?? "Something went wrong";
    }
  }

  Future<AssessmentScoreModel> saveAssessmentAnswers(
      List<Map<String, dynamic>> answers, int timeTook) async {
    final bodyMap = {
      "answerData": answers,
      "assessmentCompletionTime": timeTook,
      "assessmentId": answers.first['assessmentId']
    };
    final response = await post(
      Uri.parse("${URLConstants.saveAssessmentAnswers}/$userId"),
      body: jsonEncode(bodyMap),
      headers: {'Content-Type': 'application/json'},
    );
    final jsonBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonBody["data"] is Map) {
        return AssessmentScoreModel.fromRawJson(jsonBody["data"]);
      } else {
        throw jsonBody['message'];
      }
    } else {
      throw response.body.isEmpty
          ? "Something went wrong"
          : jsonBody['message'] ?? "Something went wrong";
    }
  }
}
