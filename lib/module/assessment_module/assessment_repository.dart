import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/assessment_module/model/assessment_model.dart';
import 'package:i_densfa/module/assessment_module/model/get_all_questions_model.dart';
import 'package:i_densfa/module/assessment_module/model/get_all_sections_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/image_compression_helper.dart';
import 'package:image_picker/image_picker.dart';

class AssessmentRepository {
  final userId = AppStorage().userDetail?.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  final client = CustomHttpBaseClient.instance;

  Future<List<AssessmentListItemModel>> getAssessment() async {
    final response = await client.get(
        Uri.parse("${URLConstants.getAllAssessmentList}/client")
            .replace(queryParameters: {'userId': userId.toString()}));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => AssessmentListItemModel.fromJson(e))
          .where((element) => element.status == "PUBLISHED")
          .where((element) => !element.isNegative())
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<AssessmentLevel>> getAssessmentLevel(
      String assessmentUuid) async {
    final response = await client.get(
        Uri.parse("${URLConstants.getAllAssessmentLevel}/v2/$assessmentUuid")
            .replace(queryParameters: {'userId': userId.toString()}));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => AssessmentLevel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<AssessmentLevel>> getAllLevel(String? assessmentUuid) async {
    final response = await client.get(Uri.parse(
        "${URLConstants.getAllAssessmentList}/$assessmentUuid/level"));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => AssessmentLevel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<GetAllSectionsModel>> getAllSections(
      String uuid, String assessmentUuid) async {
    final response = await client.get(Uri.parse(
        "${URLConstants.getAllAssessmentList}/$assessmentUuid/level/$uuid/section"));
    if (response.statusCode == 200) {
      return getAllSectionsModelFromJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<GetQuestionsModel>> getAllQuestions(
      String assessmentUuid, String levelUuid, String sectionId) async {
    final response = await client.get(Uri.parse(
        "${URLConstants.getAllAssessmentList}/$assessmentUuid/level/$levelUuid/section/$sectionId/question"));
    if (response.statusCode == 200) {
      return getQuestionsModelFromJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<AssessmentResponse> saveAssessmentAnswers(
      Map<String, dynamic> bodyMap) async {
    debugPrint(jsonEncode(bodyMap));
    Response response = await client.post(
        Uri.parse(
                "${URLConstants.getAllAssessmentLevel}/${bodyMap['assessmentUuid'].toString()}/response")
            .replace(queryParameters: {'userId': userId.toString()}),
        body: jsonEncode(bodyMap));

    if (response.statusCode == 200) {
      return AssessmentResponse.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<String> getImageUrlPath(String imagePath) async {
    return await ImageCompressionHelper.instance.uploadCompressedImage(
      imagePath,
      'assessment',
      URLConstants.saveCampaignImage,
      'assessment',
    );
  }

  Future<XFile?> compressImage(String file, {int? reduceSize}) async {
    return await ImageCompressionHelper.instance.compressImageAsXFile(
      file,
      'assessment',
      quality: reduceSize,
    );
  }

}
