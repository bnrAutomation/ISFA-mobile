import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:i_densfa/module/campaign_module/new_models/question.dart';
import 'package:i_densfa/module/my_schedule_module/store_list_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/handler.dart';

import 'beat_plan_model.dart';
import 'mechanic_visit_model.dart';

class MyScheduleRepository {
  final int companyId = AppStorage().homeInfo!.userInfo.companyId;
  final int userId;

  final httpClient = CustomHttpBaseClient.instance;
  MyScheduleRepository(int? forUserId)
      : userId = forUserId ?? AppStorage().userDetail!.id;

  Future<List<BeatPlanModel>> getBeatPlans(DateTime date) async {
    final response = await httpClient.post(
        Uri.parse(AppStorage().userDetail?.role.toLowerCase() == "supervisor"
            ? URLConstants.beatPlansSuper
            : URLConstants.beatPlans),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "date": date.toStringFormat("yyyy-MM-dd"),
          "userId": userId,
          "companyId": companyId
        }));

    if (kDebugMode) {
      debugPrint(AppStorage().userDetail?.role);
    }
    if (response.statusCode == 200) {
      final dataResponse = json.decode(response.body)["data"];
      final List plans = dataResponse is List ? dataResponse : [];
      if (plans.isNotEmpty) {
        return plans.map((e) => BeatPlanModel.fromJson(e)).toList();
      } else {
        throw getErrorMessage(response);
      }
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<MechanicVisitModel>> getMechanicVisits(DateTime date) async {
    final uri =
        Uri.parse(URLConstants.mechanicVisits).replace(queryParameters: {
      'userId': userId.toString(),
      'date': date.toStringFormat('yyyy-MM-dd'),
      "companyId": companyId.toString()
    });
    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List rows = decoded is List ? decoded : [];
      return rows
          .map((e) =>
              MechanicVisitModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<MechanicModel>> getAllMechanics() async {
    Uri uri = ["mobil", "exxonmobil"]
            .contains(AppStorage().userDetail?.companyName.toLowerCase().trim())
        ? Uri.parse("${URLConstants.baseURLStart}/iSFA/mechanic/$userId")
        : Uri.parse(URLConstants.mechanicAll);

    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List rows = decoded is List ? decoded : [];
      return rows
          .map((e) =>
              MechanicModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<StoreItemModel>> getStores() async {
    Uri uri = ["mobil", "exxonmobil"]
            .contains(AppStorage().userDetail?.companyName.toLowerCase().trim())
        ? Uri.parse("${URLConstants.baseURLStart}/iSFA/recruiter/$userId")
        : Uri.parse('${URLConstants.getStores}/$companyId');

    final response = await httpClient.get(uri);
    if (response.statusCode == 200) {
      if ([
        "mobil",
        "exxonmobil"
      ].contains(AppStorage().userDetail?.companyName.toLowerCase().trim())) {

         return (json.decode(response.body) as List)
          .map((e) => StoreItemModel.fromJson(e))
          .toList();
      } else {
        final dataList = json.decode(response.body)["dataList"];
        final List stores = dataList is List ? dataList : [];
        if (stores.isNotEmpty) {
          return stores.map((x) => StoreItemModel.fromJson(x)).toList();
        } else {
          throw getErrorMessage(response);
        }
      }
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> saveMechanicVisit({
    required int mechanicId,
    required DateTime date,
    String? remarks,
  }) async {
    final body = <String, dynamic>{
      'userId': userId,
      'mechanicId': mechanicId,
      'date': date.toStringFormat('yyyy-MM-dd'),
    };
    final trimmedRemarks = remarks?.trim();
    if (trimmedRemarks != null && trimmedRemarks.isNotEmpty) {
      body['remarks'] = trimmedRemarks;
    }

    final response = await httpClient.post(
      Uri.parse(URLConstants.mechanicVisits),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return true;
    }
    throw getErrorMessage(response);
  }

  Future<bool> beatPlanUpload(DateTime date, String reason, int storeId) async {
    final response =
        await httpClient.post(Uri.parse(URLConstants.beatPlanUpload),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "companyId": companyId,
              "pjpDate": date.toStringFormat("yyyy-MM-dd"),
              "remarks": reason,
              "storeId": storeId,
              "userId": userId,
              "createdBy": AppStorage().userDetail?.role,
              "active": "true"
            }));
    if (response.statusCode != 200) {
      throw getErrorMessage(response);
    } else {
      return true;
    }
  }
}
