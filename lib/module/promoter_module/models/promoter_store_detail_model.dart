import 'dart:convert';

class PromoterStoreDetailModel {
  PromoterStoreDetailModel(
      {required this.clusterId,
      required this.storeId,
      required this.storeCode,
      required this.name,
      required this.address,
      required this.storeCategory,
      required this.storeBranch,
      required this.storeType,
      required this.activeStatus,
      required this.markIn,
      required this.zipcode,
      required this.latitude,
      required this.longtitude});

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
  int zipcode;
  String? latitude;
  String? longtitude;

  factory PromoterStoreDetailModel.fromRawJson(String str) =>
      PromoterStoreDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PromoterStoreDetailModel.fromJson(Map<String, dynamic> json) =>
      PromoterStoreDetailModel(
          clusterId: json["clusterId"],
          storeId: json["storeId"],
          storeCode: json["storeCode"],
          name: json["name"],
          address: json["address"],
          storeCategory: json["storeCategory"],
          storeBranch: json["storeBranch"],
          storeType: json["storeType"],
          activeStatus: json["activeStatus"],
          markIn: json["markIn"] ?? false,
          zipcode: json["zipcode"],
          longtitude: json['longtitude'],
          latitude: json['latitude']);

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
        "longtitude": longtitude
      };
}
