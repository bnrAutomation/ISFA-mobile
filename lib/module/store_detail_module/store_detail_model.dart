import 'dart:convert';

class GetStoreDetailDataModel {
  GetStoreDetailDataModel({
    required this.clusterId,
    required this.storeId,
    required this.storeCode,
    required this.name,
    required this.address,
    required this.storeCategory,
    required this.storeBranch,
    required this.storeType,
    required this.activeStatus,
    required this.zipcode,
    required this.userNote,
    required this.latitude,
    required this.longitude,
    required this.phoneNo,
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
  double latitude;
  double longitude;
  String phoneNo;
  int zipcode;
  List<String> userNote;

  factory GetStoreDetailDataModel.fromRawJson(String str) =>
      GetStoreDetailDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetStoreDetailDataModel.fromJson(Map<String, dynamic> json) =>
      GetStoreDetailDataModel(
        clusterId: json["clusterId"],
        storeId: json["storeId"],
        storeCode: json["storeCode"],
        name: json["name"],
        address: json["address"],
        storeCategory: json["storeCategory"],
        storeBranch: json["storeBranch"],
        storeType: json["storeType"],
        activeStatus: json["activeStatus"],
        zipcode: json["zipcode"],
        phoneNo: json['phoneNo'],
        latitude: double.tryParse(json['latitude'].toString()) ?? 0,
        longitude: double.tryParse(json['logitude'].toString()) ?? 0,
        userNote: List<String>.from(json["userNote"].map((x) => x)),
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
        "zipcode": zipcode,
        "logitude": longitude,
        "latitude": latitude,
        "phoneNo": phoneNo,
        "userNote": List<dynamic>.from(userNote.map((x) => x)),
      };
}
