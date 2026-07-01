import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/filled_campaign_list.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/utility/image_compression_helper.dart';
import 'package:i_densfa/module/promoter_module/feedback/model/feedback_model.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';
import 'package:i_densfa/utility/services/markin_markout_offline_service.dart';

class StoreDetailRepository {
  final userId = AppStorage().userDetail?.id;
  final client = CustomHttpBaseClient.instance;
  final MarkinMarkoutOfflineService _markinMarkoutOfflineService = MarkinMarkoutOfflineService();

  Future<List<AllCampaignModel>> getCampaignsForStore(String storeId) async {
    final uri = Uri.parse(URLConstants.getAllCampaigns).replace(
        queryParameters: {'userId': userId.toString(), "storeId": storeId});
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => AllCampaignModel.fromJson(e))
          .where((element) => element.status == "PUBLISHED")
          .where((element) => !element.isNegative())
          .toList();
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<String>> getFilledCampaign(int storeId) async {
    final response = await client.get(
      Uri.parse(URLConstants.getAllClientCampaigns).replace(queryParameters: {
        'userId': userId.toString(),
        "storeId": storeId.toString()
      }),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${AppStorage().authToken}",
      },
    );
    if (response.statusCode == 200) {
      return FilledCampaignList.fromRawJson(response.body)
          .userCampaignResponses;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<GetStoreDetailDataModel> getStoreDetails(int storeId) async {
    final response = await client.get(
      Uri.parse("${URLConstants.getStoreDetail}/$userId/$storeId"),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${AppStorage().authToken}",
      },
    );

    if (response.statusCode == 200) {
      final dataJson = jsonDecode(response.body)['data'];
      if (dataJson == null) {
        throw 'No store found';
      }
      return GetStoreDetailDataModel.fromJson(dataJson);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<bool> addNoteForStore(String note, int storeId) async {
    final requestBody = {"note": note, "storeId": storeId, "userId": userId};
    final response = await client.post(Uri.parse(URLConstants.addNote),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${AppStorage().authToken}",
        },
        body: json.encode(requestBody));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<List<FeedbackDataList>> getFeedback(String storeName) async {
    final requestBody = {
      "storeName": storeName,
      "createdBy": AppStorage().userDetail!.id
    };
    try {
      // If completely offline, gracefully return empty feedback list
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return <FeedbackDataList>[];
      }

      final response = await client.post(
        Uri.parse(URLConstants.getFeedbackByUserIdAndStore),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${AppStorage().authToken}",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FeedbackModel.fromJson(jsonDecode(response.body)).dataList;
      } else {
        throw getErrorMessage(response);
      }
    } on SocketException {
      // Network error (offline) – treat as "no feedback" for offline mode
      return <FeedbackDataList>[];
    } catch (e) {
      // Other errors should still bubble up for proper handling
      rethrow;
    }
  }

  Future<List<AllCampaignModel>> fetchAllCampaigns() async {
    final response = await client.get(
      Uri.parse(URLConstants.getAllCampaignsList),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppStorage().authToken}',
      },
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> rawList =
          body is List ? body : (body['data'] as List? ?? []);
      return rawList
          .map((e) => AllCampaignModel.fromJson(e as Map<String, dynamic>))
          .where((element) => element.status == 'PUBLISHED')
          .where((element) => !element.isNegative())
          .toList();
    }
    throw getErrorMessage(response);
  }

  Future<bool> postStoreBeatPlan({
    required int storeId,
    required String campaignUuid,
    required DateTime visitDate,
    required String agenda,
  }) async {
    final response = await client.post(
      Uri.parse(URLConstants.storeBeatPlan),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppStorage().authToken}',
      },
      body: json.encode({
        'storeId': storeId,
        'campaignUuid': campaignUuid,
        'visitDate': visitDate.toStringFormat('yyyy-MM-dd'),
        'agenda': agenda,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    throw getErrorMessage(response);
  }

  Future<bool> deleteNoteForStore(int noteId) async {
    final response = await client.delete(
      Uri.parse('${URLConstants.deleteNote}/$noteId'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${AppStorage().authToken}",
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<String> markInOutStore(
      {required XFile? uploadFile,
      required double latitude,
      required double longitude,
      required int pjpId,
      required int storeId,
      required bool isIn,
      required bool isImage,
      required bool geofence,
      required int distance,
      bool bySync = false}) async {
    // Initialize offline service
    await _markinMarkoutOfflineService.init();
    
    // Check if online
    final isOnline = await _markinMarkoutOfflineService.isOnline();
    
    // Store image path for offline use
    String? imagePath;
    if (uploadFile != null) {
      imagePath = uploadFile.path;
    }
    
    if (!isOnline) {
      // Queue for offline submission
      final submissionId = await _markinMarkoutOfflineService.queueMarkinMarkout(
        imageFile: uploadFile,
        latitude: latitude,
        longitude: longitude,
        storeId: storeId,
        pjpId: pjpId,
        isIn: isIn,
        isImage: isImage,
        geofence: geofence,
        distance: distance,
        imagePath: imagePath ?? '',
        bySync: false, // User action, will be true when auto-syncing
      );
      
      throw OfflineMarkinMarkoutException(
        'Mark${isIn ? 'In' : 'Out'} saved offline. Will be submitted when online.',
        submissionId: submissionId,
      );
    }
    
    // Online submission - existing code with bySync flag
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    final url = Uri.parse(isIn ? URLConstants.markin : URLConstants.markOut);
    final request = MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer ${AppStorage().authToken}',
    });
    if (AppStorage().userDetail?.configuration.requiredSelfieForMarkIn ??
        true) {
      final file = await compressImage(uploadFile!, isIn);
      final multipartFile = await MultipartFile.fromPath(
        'file',
        file!.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }
    String address = "Fetching address...";
     address =  await  _getAddressFromLatLng(latitude,longitude);
    request.fields.addAll({
      "userId": userId.toString(),
      "storeId": storeId.toString(),
      "status": isIn.toString(),
      "pjpId": pjpId.toString(),
      "timeZone": currentTimeZone,
      "campaignId": AppStorage().userDetail?.companyId.toString()??"-1",
      "requiredImage": isImage.toString(),
      "requiredGeofence": geofence.toString(),
      "distance": distance.toString(),
      "activity": isIn ? "markin" : "markout",
      "bySync": bySync.toString(), // Add bySync flag
    });
    if (isIn) {
      request.fields.addAll({
        "inLatitude": latitude.toString(),
        "inLongitude": longitude.toString(),
          "inLocation":address,
        "i18nMarkInTime": DateTime.now().toUtc().toString()
      });
    } else {
      request.fields.addAll({
        "outLatitude": latitude.toString(),
        "outLongitude": longitude.toString(),
          "outLocation":address,
        "i18nMarkOutTime": DateTime.now().toUtc().toString()
      });
    }
    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      return json.decode(body)['message'] ?? "";
    } else {
      throw getErrorMessageSteam(response, body);
    }
  }
  
  // Get offline service instance for bloc access
  MarkinMarkoutOfflineService get markinMarkoutOfflineService => _markinMarkoutOfflineService;


  Future<String> _getAddressFromLatLng(double lat, double lng) async {
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

  Future<XFile?> compressImage(XFile file, bool isIn, {int? reduceSize}) async {
    String name = isIn ? "markin" : "markout";
    return await ImageCompressionHelper.instance.compressImageAsXFile(
      file.path,
      name,
      quality: reduceSize,
    );
  }

}
