import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';
import 'package:i_densfa/module/campaign_module/new_models/campaign.dart';
import 'package:i_densfa/module/campaign_module/new_models/filled_campaign_list.dart';
import 'package:i_densfa/module/promoter_module/models/check_activity_model.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/campaign_module/campaign_model.dart';
import 'package:i_densfa/module/promoter_module/models/inventory_detail_model.dart';
import 'package:i_densfa/module/promoter_module/models/promoter_store_detail_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/services/markin_markout_offline_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PromoterRepository {
  final userId = AppStorage().userDetail!.id;
  final companyId = AppStorage().homeInfo!.userInfo.companyId;
  final client = CustomHttpBaseClient.instance;
  final MarkinMarkoutOfflineService _markinMarkoutOfflineService = MarkinMarkoutOfflineService();


    Future<CheckActivityData> checkActivity(int storeId) async {
    final response = await client.get(
        Uri.parse(URLConstants.checkActivity).replace(queryParameters: {"userId":userId.toString(),"storeId":storeId.toString()}));
    //final resJson = json.decode(response.body);
    if (response.statusCode == 200) {
      return ChackActivityModel.fromRawJson(response.body).activityData;
    } else {
      throw getErrorMessage(response);
    }
  }



  Future<PromoterStoreDetailModel> getStoreDetails() async {
    final response = await client.get(
        Uri.parse('${URLConstants.promoterStoreDetail}/$userId/$companyId'));
    final resJson = json.decode(response.body);
    if (response.statusCode == 200 && resJson['data'] is Map) {
      return PromoterStoreDetailModel.fromJson(resJson['data']);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<InventoryDetailModel> getInventoryDetail(int storeId) async {
    final response = await client.get(
        Uri.parse('${URLConstants.getInventory}/$userId/$companyId/$storeId'));
    final resJson = json.decode(response.body);
    if (response.statusCode == 200 && resJson['data'] is Map) {
      return InventoryDetailModel.fromJson(resJson['data']);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<String> markInOutStore(
      XFile? uploadFile,
      double latitude,
      double longitude,
      int storeId,
      bool isIn,
      bool isImage,
      bool geofence,
      int distance,
      {bool bySync = false}) async {
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
      //  final file = await compressImage(uploadFile!);
      final multipartFile = await MultipartFile.fromPath(
          'file', uploadFile!.path,
          contentType: MediaType('image', 'webp'));
      request.files.add(multipartFile);
    }
    // final file = await compressImage(uploadFile);
    // request.files.add(await MultipartFile.fromPath('file', file!.path));

     String address = "Fetching address...";
     address =  await  _getAddressFromLatLng(latitude,longitude);
    request.fields.addAll({
      "userId": userId.toString(),
      "storeId": storeId.toString(),
      "status": isIn.toString(),
      "timeZone": currentTimeZone,
      "campaignId": companyId.toString(),
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
        "i18nMarkInTime": DateTime.now().toUtc().toString(),
          "inLocation":address
        // "localStart": DateTime.now().toLocal().toString()
      });
    } else {
      request.fields.addAll({
        "outLatitude": latitude.toString(),
        "outLongitude": longitude.toString(),
        "i18nMarkOutTime": DateTime.now().toUtc().toString(),
         "outLocation":address
        //"localEnd": DateTime.now().toLocal().toString()
      });
    }

    final response = await request.send();
    String body = await response.stream.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      return json.decode(body)['message'] ?? "";
    } else {
      final bod = jsonDecode(body);
      final String mess = bod['message'] ?? bod["error"];
      throw mess;
      //throw getErrorMessage(body);
    }
  }
  
  // Get offline service instance for bloc access
  MarkinMarkoutOfflineService get markinMarkoutOfflineService => _markinMarkoutOfflineService;


  Future<String> _getAddressFromLatLng(double lat, double lng) async {
  try {
    for (int i = 0; i < 3; i++) {
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          return "${p.name}, ${p.locality}, ${p.administrativeArea}, ${p.country}";
        }
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return "Address not found";
  } catch (e) {
    return "Error: $e";
  }
}


  // Future<String> _getAddressFromLatLng(double lat, double lng) async {
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

  //     if (placemarks.isNotEmpty) {
  //       final place = placemarks.first;
       
  //         return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    
  //     } else {
       
  //        return"No address found";
       
  //     }
  //   } catch (e) {
  //       return "Error: $e";
  
  //   }
  // }

  Future<List<CampaignDetailModel>> getCompaignList(int storeId) async {
    final response =
        await client.get(Uri.parse("${URLConstants.getCompaingns}/$storeId"));

    if (response.statusCode == 200) {
      return UserCampaignsModel.fromRawJson(response.body).dataList ?? [];
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<XFile?> compressImage(XFile file, {int? reduceSize}) async {
    final directory =
        "${await _getExternalStoragePath()}/${basename(file.path)}";
    final int size = reduceSize ?? 90;

    final img = await FlutterImageCompress.compressAndGetFile(
      file.path,
      directory,
      quality: size,
    );
    final listImg = await img?.readAsBytes();
    // checking if file size if more than 400 Kb then futher reduce it
    if ((listImg?.lengthInBytes ?? 0) / 1024.0 > 400) {
      return await compressImage(file, reduceSize: size - 10);
    }
    return img;
  }

  Future<String> _getExternalStoragePath() async {
    if (Platform.isIOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getExternalStorageDirectory())?.path ?? "";
    }
  }

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

  Future<List<String>> getFilledCampaign(String storeId) async {
    final response = await client.get(
      Uri.parse(URLConstants.getAllClientCampaigns).replace(
          queryParameters: {'userId': userId.toString(), "storeId": storeId}),
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
}
