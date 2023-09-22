import 'dart:convert';

class PromoterStoreDetailModel {
  PromoterStoreDetailModel({
    required this.clusterId,
    required this.storeId,
    required this.storeCode,
    required this.name,
    required this.address,
    required this.storeCategory,
    required this.storeBranch,
    required this.storeType,
    required this.activeStatus,
    required this.markIn,
    required this.alreadyMarkout,
    required this.zipcode,
    required this.latitude,
    required this.longitude,
    required this.phoneNo,
    required this.storeImage1,
  });

  int clusterId;
  int storeId;
  String storeCode;
  String name;
  String address;
  String storeCategory;
  String storeBranch;
  String storeType;
  bool activeStatus;
  bool markIn;
  bool alreadyMarkout;
  int zipcode;
  double latitude;
  double longitude;
  String phoneNo;
  String storeImage1;
  factory PromoterStoreDetailModel.fromRawJson(String str) =>
      PromoterStoreDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PromoterStoreDetailModel.fromJson(Map<String, dynamic> json) =>
      PromoterStoreDetailModel(
        clusterId: json["clusterId"] ?? -1,
        storeId: json["storeId"],
        storeCode: json["storeCode"],
        name: json["name"],
        address: json["address"],
        storeCategory: json["storeCategory"],
        storeBranch: json["storeBranch"],
        storeType: json["storeType"],
        activeStatus: json["activeStatus"],
        markIn: json["markIn"] ?? false,
        alreadyMarkout: json["alreadyMarkout"] ?? false,
        zipcode: json["zipcode"],
        phoneNo: json['phoneNo'],
        storeImage1: json['storeImage1'] ?? "",
        latitude: double.tryParse(json['latitude'].toString()) ?? 0,
        longitude: double.tryParse(json['logitude'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "clusterId": clusterId,
        "storeId": storeId,
        "storeCode": storeCode,
        "name": name,
        "address": address,
        "storeCategory": storeCategory,
        "storeBranch": storeBranch,
        "storeType": storeType,
        "activeStatus": activeStatus,
        "markIn": markIn,
        "zipcode": zipcode,
        "latitude": latitude,
        "logitude": longitude,
        "phoneNo": phoneNo,
        "alreadyMarkout": alreadyMarkout,
        "storeImage1": storeImage1
      };
}
