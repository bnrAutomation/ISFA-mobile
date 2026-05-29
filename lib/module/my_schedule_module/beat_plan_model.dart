import 'dart:convert';

class StoreResponse {
  final String message;
  final String status;
  final List<BeatPlanModel> dataList;
  final int totalPages;
  final int totalRecords;
  final int pageSize;

  StoreResponse({
    required this.message,
    required this.status,
   required this.dataList,
    required this.totalPages,
    required this.totalRecords,
    required this.pageSize,
  });

  factory StoreResponse.fromRawJson(String str) =>
      StoreResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoreResponse.fromJson(Map<String, dynamic> json) {
    return StoreResponse(
      message: json['message'] ??"",
      status: json['status']??"",
      dataList:  List.from(json['dataList'] ?? [])
        .map((e) => BeatPlanModel.fromJson(e))
        .toList(),
      totalPages: json['totalPages']??0,
      totalRecords: json['totalRecords']??0,
      pageSize: json['pageSize'] ??0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'dataList': dataList.map((e) => e.toJson()).toList(),
      'totalPages': totalPages,
      'totalRecords': totalRecords,
      'pageSize': pageSize,
    };
  }
}
class BeatPlanModel {
  BeatPlanModel({
    required this.pjpId,
    required this.markin,
    required this.isAlreadyMarkin,
    required this.storeId,
    required this.pjpDate,
    required this.storeName,
    required this.storeCategory,
    required this.address,
    this.latitude,
    this.longitude,
    required this.activeStatus,
    required this.storeImage1,
    required this.storecode,
    this.mobileNumber,
    required this.campaignResponseExists,
    required this.supervisor,
    this.formFilledBy,
    required this.assignedUsers,
      required this.mechanicContact,
       required this.mechanicName,
  });

  int pjpId;
  int storeId;
  DateTime pjpDate;
  String storeName;
  String storeCategory;
  String address;
  bool markin;
  bool isAlreadyMarkin;
  double? latitude;
  double? longitude;
  bool activeStatus;
  String storeImage1;
  String storecode;
  dynamic mobileNumber;
  bool campaignResponseExists;
  String supervisor;
  String? formFilledBy;
  List<String>? assignedUsers;
  final String mechanicContact;
   final String mechanicName;
  

  factory BeatPlanModel.fromRawJson(String str) =>
      BeatPlanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BeatPlanModel.fromJson(Map<String, dynamic> json) => BeatPlanModel(
        pjpId: json["pjpId"]??-1,
        storeId: json["storeId"],
        markin: json["markin"] ?? false,
        isAlreadyMarkin: json["alreadyMarkout"] ?? false,
        pjpDate:  json["pjpDate"]==null?DateTime.now():DateTime.parse(json["pjpDate"]),
        storeName: json["storeName"]?? json['name']??"",
        storeCategory: json["storeCategory"] ?? '',
        address: json["address"],
        latitude: double.tryParse((json["latitude"]??0.0).toString()),
        longitude: double.tryParse((json["longitude"]??0.0).toString()),
        activeStatus: json["activeStatus"] is String ? json["activeStatus"]=='true':json["activeStatus"],
        storeImage1: json["storeImage1"] ?? "",
        storecode: json["storecode"]??json['storeCode']??"",
        mobileNumber: json["mobileNumber"]?? json["phoneNo"]??"",
        campaignResponseExists: (json["campaignResponseExists"]??"0")==1,
        supervisor:json["supervisor"]??"",
        formFilledBy: json["formFilledBy"]?.toString(),
        assignedUsers: json['assignedUsers'] != null
            ? List<String>.from(json['assignedUsers'] as List)
            : <String>[],
         mechanicContact: json['mechanicContact']?.toString() ?? '',
        mechanicName: json['mechanicName']?.toString() ?? ''
      );

  Map<String, dynamic> toJson() => {
        "pjpId": pjpId,
        "storeId": storeId,
        "pjpDate":"${pjpDate.year.toString().padLeft(4, '0')}-${pjpDate.month.toString().padLeft(2, '0')}-${pjpDate.day.toString().padLeft(2, '0')}",
        "storeName": storeName,
        "storeCategory": storeCategory,
        "address": address,
        "latitude": latitude,
        "markin": markin,
        "longitude": longitude,
        "activeStatus": activeStatus,
        "storeImage1": storeImage1,
        "storecode": storecode,
        "mobileNumber": mobileNumber,
        "alreadyMarkout": isAlreadyMarkin,
        "campaignResponseExists" :(campaignResponseExists?1:0).toString(),
        "supervisor": supervisor,
        "formFilledBy": formFilledBy,
        "assignedUsers" : assignedUsers
      };
}
