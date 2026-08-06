import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_model.dart';
import 'package:i_densfa/module/survey_module/models/filled_survey_response_model.dart';
import 'package:i_densfa/module/survey_module/models/survey_form_question_model.dart';
import 'package:i_densfa/module/survey_module/models/survey_form_section_model.dart';
import 'package:i_densfa/module/survey_module/models/survey_model.dart';
import 'package:i_densfa/module/survey_module/models/survey_scheduled_visit_model.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SurveyRepository {
  final userId = AppStorage().userDetail?.id;
  final compId = AppStorage().homeInfo!.userInfo.companyId;
  final client = CustomHttpBaseClient.instance;

  Future<StoreNoteModel> addNoteForSurveys(
      String note, String surveyUuid) async {
    final requestBody = {
      "note": note,
      "surveyUuid": surveyUuid,
      "userId": userId
    };

    final response = await client.post(
        Uri.parse(URLConstants.createSurveyNotes),
        body: json.encode(requestBody));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return StoreNoteModel.fromJson(json.decode(response.body));
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<StoreNoteModel>> getNoteForSurveys(String surveyUuid) async {
    final response = await client
        .get(Uri.parse("${URLConstants.createSurveyNotes}/$surveyUuid"));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => StoreNoteModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<FilledSurveyApiResponse> getFilledSurveys(
      String surveyUuid, int pageOffset) async {
    final response = await client.get(Uri.parse(
            "${URLConstants.surveyServiceBaseUrl}/client/survey/$surveyUuid/response")
        .replace(queryParameters: {
      "userId": userId.toString(),
      "pageOffset": pageOffset.toString(),
      "pageSize": 10.toString()
    }));
    if (response.statusCode == 200) {
      return FilledSurveyApiResponse.fromRawJson(response.body);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> deleteNoteForSurveys(int noteId) async {
    final response = await client.delete(
      Uri.parse('${URLConstants.createSurveyNotes}/$noteId'),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> scheduleSurveysVisit(String surveyUuid, String clientName,
      DateTime visitDate, String agenda) async {
    final requestBody = {
      "userId": userId,
      "surveyUuid": surveyUuid,
      "clientName": clientName,
      "visitDate": visitDate.toStringFormat("yyyy-MM-dd"),
      "agenda": agenda
    };

    final response = await client.post(
        Uri.parse("${URLConstants.surveyServiceBaseUrl}/beatPlan"),
        body: json.encode(requestBody));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<SurveyScheduledVisitModel>> getSurveyScheduledVisits(
      DateTime date, String surveyUuid) async {
    final requestBody = {
      "visitDate": date.toStringFormat("yyyy-MM-dd"),
      "surveyUuid": surveyUuid,
      "userId": userId.toString()
    };

    final response = await client.post(
        Uri.parse(URLConstants.getSurveyBeatPlans),
        body: json.encode(requestBody));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => SurveyScheduledVisitModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getClient(String surveyUuid) async {
    final uri = Uri.parse("${URLConstants.surveyServiceBaseUrl}/client/name")
        .replace(queryParameters: {
      "surveyUuid": surveyUuid,
      "userId": userId.toString()
    });
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => e.toString())
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<SurveyListItemModel>> getSurveys() async {
    final uri = Uri.parse("${URLConstants.getAllSurveysList}/client")
        .replace(queryParameters: {'userId': userId.toString()});
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => SurveyListItemModel.fromJson(e))
          .where((element) => element.status == "PUBLISHED")
          .where((element) => !element.isNagative())
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<SurveyFormSectionModel>> getSections(
      {required String surveyUuid}) async {
    final response = await client.get(
      Uri.parse("${URLConstants.getAllSurveysList}/$surveyUuid/section"),
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => SurveyFormSectionModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<SurveyFormQuestionModel>> getQuestions(
      {required String surveyUuid, required String sectionUuid}) async {
    final response = await client.get(
      Uri.parse(
          "${URLConstants.getAllSurveysList}/$surveyUuid/section/$sectionUuid/question"),
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => SurveyFormQuestionModel.fromJson(e))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getPromoter() async {
    final response = await client.get(
        Uri.parse("${URLConstants.surveyServiceBaseUrl}/userdata/searchBySup")
            .replace(
                queryParameters: {'sup': AppStorage().userDetail?.username}));
    if (response.statusCode == 200) {
      return OptionList.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getCity() async {
    final response = await client.get(Uri.parse(
        "${URLConstants.surveyServiceBaseUrl}/userdata/getAllCities"));
    if (response.statusCode == 200) {
      return OptionList.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getCityByDistrict(String district) async {
    final response = await client.get(Uri.parse(
        "${URLConstants.surveyServiceBaseUrl}/userdata/cities/$district"));
    if (response.statusCode == 200) {
      return OptionList.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getDistrictByState(String state) async {
    final response = await client.get(Uri.parse(
        "${URLConstants.surveyServiceBaseUrl}/userdata/districts/$state"));
    if (response.statusCode == 200) {
      return OptionList.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getPromoterByDistrict(String district) async {
    final response = await client.get(Uri.parse(
        "${URLConstants.surveyServiceBaseUrl}/userdata/district/$district"));
    if (response.statusCode == 200) {
      return OptionList.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getOncallState() async {
    final response = await client
        .get(Uri.parse("${URLConstants.surveyServiceBaseUrl}/userdata/states"));
    if (response.statusCode == 200) {
      return OptionList.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getOncallBrand() async {
    final response = await client
        .get(Uri.parse("${URLConstants.surveyServiceBaseUrl}/userdata/brands"));
    if (response.statusCode == 200) {
      return OptionList.fromRawJson(response.body).data;
    } else {
      throw getErrorMessage(response);
    }
  }

   Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
          return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    
      } else {
         return"No address found";
       
      }
    } catch (e) {
        return "Error: $e";
  
    }
  }



  Future<bool> saveSurveyAnswers(
      Map<String, dynamic> bodyMap, bool updatePrevious, String uriID) async {
    final uri = Uri.parse(
            "${URLConstants.baseURLStart}/survey-service/iSFA/api/v1/client/survey/$uriID/response")
        .replace(queryParameters: {'userId': userId.toString()});
    Response response;
    //debugPrint(jsonEncode(bodyMap));
    if (updatePrevious) {
      response = await client.put(
        uri,
        body: jsonEncode(bodyMap),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
    } else {
      response = await client.post(
        uri,
        body: jsonEncode(bodyMap),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
    }
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<SavedQuestion>> getSavedQuestions(
      String surveyUuid, String sectionUuid, String responseUuid) async {
    String apiUrl =
        '${URLConstants.baseURLStart}/survey-service/iSFA/api/v1/client/survey/getQuestionsResponse/$surveyUuid/$sectionUuid/$responseUuid';

    try {
      final response = await client.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((questionData) => SavedQuestion.fromJson(questionData))
            .toList();
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<String> _getExternalStoragePath() async {
    final direct = Platform.isIOS
        ? getApplicationDocumentsDirectory()
        : getExternalStorageDirectory();
    final dir = await direct;
    return dir?.path ?? "";
  }

  Future<XFile?> compressImage(String file, {int? reduceSize}) async {
     final now = DateTime.now();
    final formattedDate = DateFormat("yyyyMMdd'T'HH:mm:ss").format(now);
    final directory =
        "${await _getExternalStoragePath()}/${AppStorage().userDetail?.id}_survey_${formattedDate}_${basename(file)}";
    int size = reduceSize ?? 90;
    final img = await FlutterImageCompress.compressAndGetFile(
      file,
      directory,
      quality: size,
    );
    final listImg = await img?.readAsBytes();
    if ((listImg?.lengthInBytes ?? 0) / 1024.0 > 400) {
      return await compressImage(file, reduceSize: size - 10);
    }
    return img;
  }

  Future<String> getImageUrlPath(String imagePath) async {
    XFile? filePath = (await compressImage(imagePath));
    final url = Uri.parse(URLConstants.saveCampaignImage);
    final request = MultipartRequest('POST', url);
    request.headers
        .addAll({'Authorization': 'Bearer ${AppStorage().authToken}'});
    final multipartFile = await MultipartFile.fromPath(
      'image',
      filePath!.path,
      contentType: MediaType('image', 'webp'),
    );
    request.files.add(multipartFile);
    request.fields.addAll({"activity": "survay"});
    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();
    if (response.statusCode == 201) {
      return jsonDecode(body)['imageUrl'];
    } else {
      throw getErrorMessageSteam(response, body);
    }
  }

  // Future<String> getImageUrlPath(String imagePath, String question) async {
  //   XFile? filePath = (await compressImage(imagePath));

  //   final url = Uri.parse(
  //       '${URLConstants.baseURLStart}/survey-service/iSFA/api/v1/survey/image');
  //   final request = MultipartRequest('POST', url);
  //   request.headers
  //       .addAll({'Authorization': 'Bearer ${AppStorage().authToken}'});

  //   final multipartFile = await MultipartFile.fromPath(
  //       'image', filePath?.path ?? imagePath,
  //       filename:
  //           "${question.replaceAll(" ", "_")}_${userId}_${DateTime.now().microsecondsSinceEpoch}${extension(filePath!.path)}");
  //   request.files.add(multipartFile);

  //   final response = await request.send();
  //   String body = await response.stream.transform(utf8.decoder).join();

  //   if (response.statusCode == 201) {
  //     return jsonDecode(body)['imageUrl'];
  //   } else {
  //     final bod = jsonDecode(body);
  //     final String mess = bod['message'] ?? bod["error"];
  //     throw mess;
  //   }
  // }

  String extension(String path, [int level = 1]) =>
      context.extension(path, level);
}
