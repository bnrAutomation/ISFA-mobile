import 'dart:convert';

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

  factory BeatPlanModel.fromRawJson(String str) =>
      BeatPlanModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BeatPlanModel.fromJson(Map<String, dynamic> json) => BeatPlanModel(
        pjpId: json["pjpId"],
        storeId: json["storeId"],
        markin: json["markin"] ?? false,
        isAlreadyMarkin: json["alreadyMarkout"] ?? false,
        pjpDate: DateTime.parse(json["pjpDate"]),
        storeName: json["storeName"],
        storeCategory: json["storeCategory"],
        address: json["address"],
        latitude: double.tryParse(json["latitude"].toString()),
        longitude: double.tryParse(json["longitude"].toString()),
        activeStatus: json["activeStatus"],
        storeImage1: json["storeImage1"],
        storecode: json["storecode"],
        mobileNumber: json["mobileNumber"],
      );

  Map<String, dynamic> toJson() => {
        "pjpId": pjpId,
        "storeId": storeId,
        "pjpDate":
            "${pjpDate.year.toString().padLeft(4, '0')}-${pjpDate.month.toString().padLeft(2, '0')}-${pjpDate.day.toString().padLeft(2, '0')}",
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
        "alreadyMarkout": isAlreadyMarkin
      };
}
