import 'dart:convert';

/// Model for creating a new retailer/store
/// Matches API format: POST /iSFA/api/saveStore/{companyId}
class CreateStoreModel {
  final String storeName;
  final String storeCode;
  final String? gstNumber;
  final String phoneNo;
  final String contactName;
  final String storeType;
  final String address;
  final String city;
  final String region;
  final String state;
  final String location;
  final String zipcode;
  final double? latitude;
  final double? longitude;
  final String campaignId;
  final String userId;

  CreateStoreModel({
    required this.storeName,
    required this.storeCode,
    this.gstNumber,
    required this.phoneNo,
    required this.contactName,
    required this.storeType,
    required this.address,
    required this.city,
    required this.region,
    required this.state,
    required this.location,
    required this.zipcode,
    this.latitude,
    this.longitude,
    required this.campaignId,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        "storeName": storeName,
        "storeCode": storeCode,
        if (gstNumber != null && gstNumber!.isNotEmpty) "gst": gstNumber,
        "phoneNo": phoneNo,
        "contactName": contactName,
        "storeType": storeType,
        "address": address,
        "city": city,
        "region": region,
        "state": state,
        "location": location,
        "zipcode": zipcode,
        "latitude": latitude,
        "longitude": longitude,
        "campaignId": campaignId,
        "activity": "store",
        "userId":userId,
      };

  String toRawJson() => json.encode(toJson());

  factory CreateStoreModel.fromJson(Map<String, dynamic> json) =>
      CreateStoreModel(
        storeName: json["storeName"] ?? "",
        storeCode: json["storeCode"] ?? "",
        gstNumber: json["gst"],
        phoneNo: json["phoneNo"] ?? "",
        contactName: json["contactName"] ?? "",
        storeType: json["storeType"] ?? "",
        address: json["address"] ?? "",
        city: json["city"] ?? "",
        region: json["region"] ?? "",
        state: json["state"] ?? "",
        location: json["location"] ?? "",
        zipcode: json["zipcode"] ?? "",
        latitude: json["latitude"] != null
            ? double.tryParse(json["latitude"].toString())
            : null,
        longitude: json["longitude"] != null
            ? double.tryParse(json["longitude"].toString())
            : null,
        campaignId: json["campaignId"] ?? "-1",
        userId:json["userId"]??"-1"
      );

  factory CreateStoreModel.fromRawJson(String str) =>
      CreateStoreModel.fromJson(json.decode(str));
}

class CreateStoreResponse {
  final String message;
  final String status;
  final int? storeId;

  CreateStoreResponse({
    required this.message,
    required this.status,
    this.storeId,
  });

  factory CreateStoreResponse.fromJson(Map<String, dynamic> json) =>
      CreateStoreResponse(
        message: json["message"] ?? "",
        status: json["status"] ?? "",
        storeId: json["storeId"] ?? json["data"]?["storeId"],
      );

  factory CreateStoreResponse.fromRawJson(String str) =>
      CreateStoreResponse.fromJson(json.decode(str));
}
