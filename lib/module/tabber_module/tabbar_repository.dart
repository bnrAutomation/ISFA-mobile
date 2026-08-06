import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart';
import 'package:i_densfa/utility/handler.dart';
import 'package:i_densfa/module/tabber_module/models/side_menu_model.dart';
import 'package:i_densfa/utility/app_constants.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TabbarRepository {
  final userId = AppStorage().userDetail?.id;
  final client = CustomHttpBaseClient.instance;
  final companyId = AppStorage().userDetail?.companyId;
  final requiredSelfieForStartDuty =
      AppStorage().userDetail?.configuration.requiredSelfieForStartDuty ?? true;
  Future<SideMenuModel> getSideMenuDetails() async {
    final response = await client.get(Uri.parse(URLConstants.sidemenuDetails));
    final jsonRec = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return SideMenuModel.fromJson(jsonRec);
    } else {
      throw getErrorMessage(response);
    }
  }

  Future<String> startEndDuty(XFile? file, double latitude, double longitude,
      bool isStart, bool isImage, BuildContext context,bool requireGeo,double distance) async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    final url =
        Uri.parse(isStart ? URLConstants.startDuty : URLConstants.endDuty);
    final request = MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer ${AppStorage().authToken}',
    });

    if (requiredSelfieForStartDuty) {
      XFile? filePath = (await compressImage(file!, isStart));
      final multipartFile = await MultipartFile.fromPath(
        'file',
        filePath?.path ?? "",
        contentType: MediaType('image', 'webp'),
      );
      request.files.add(multipartFile);
    }
     String address = "Fetching address...";
     address =  await  _getAddressFromLatLng(latitude,longitude);

    request.fields.addAll({
      "userId": userId.toString(),
      "status": isStart.toString(),
      "campaignId": companyId.toString(),
      "timeZone": currentTimeZone,
      "requiredImage": isImage.toString(),
      "activity": isStart ? "startduty" : "endduty",
      "requireGeo":requireGeo.toString(),
      "distance":distance.toString()
    });

    if (isStart) {
      request.fields.addAll({
        "inLatitude": latitude.toString(),
        "inLongitude": longitude.toString(),
        "i18nStartTime": DateTime.now().toUtc().toString(),
         "inLocation":address
        //"localStart": DateTime.now().toLocal().toString()
      });
    } else {
      request.fields.addAll({
        "outLatitude": latitude.toString(),
        "outLongitude": longitude.toString(),
        "i18nEndTime": DateTime.now().toUtc().toString(),
        "outLocation":address
        // "localEnd": DateTime.now().toLocal().toString()
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

  Future<XFile?> compressImage(XFile file, bool isStart,
      {int? reduceSize}) async {
    String name = isStart ? "startduty" : "endduty";
     final now = DateTime.now();
    final formattedDate = DateFormat("yyyyMMdd'T'HH:mm:ss").format(now);
    final directory =
        "${await _getExternalStoragePath()}/${AppStorage().userDetail?.id}_${name}_${formattedDate}_${basename(file.path)}";

    int size = reduceSize ?? 90;
    final img = await FlutterImageCompress.compressAndGetFile(
      file.path,
      directory,
      quality: size,
      format: CompressFormat.webp,
    );
    final listImg = await img?.readAsBytes();
    // checking if file size if more than 1000 Kb then further reduce it
    if ((listImg?.lengthInBytes ?? 0) / 1024.0 > 400) {
      return await compressImage(file, isStart, reduceSize: size - 10);
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
}
