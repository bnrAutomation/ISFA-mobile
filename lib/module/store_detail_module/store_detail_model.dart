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
  List<StoreNoteModel> userNote;

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
        userNote: json["userNote"] is List
            ? (json["userNote"] as List)
                .map((x) => StoreNoteModel.fromJson(x))
                .toList()
            : [],
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
        "userNote": userNote.map((e) => e.toJson()).toList(),
      };
}

class StoreNoteModel {
  final String note;
  final int noteId;

  StoreNoteModel({required this.note, required this.noteId});

  factory StoreNoteModel.fromJson(Map<String, dynamic> json) =>
      StoreNoteModel(note: json['note'], noteId: json['noteId']);

  Map<String, dynamic> toJson() => {'noteId': noteId, 'note': note};
}
