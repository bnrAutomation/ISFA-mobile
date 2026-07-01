import 'dart:convert';

class StoreListModel {
  String message;
  String status;
  List<StoreItemModel> result;

  StoreListModel({
    required this.message,
    required this.status,
    required this.result,
  });

  factory StoreListModel.fromRawJson(String str) =>
      StoreListModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoreListModel.fromJson(Map<String, dynamic> json) => StoreListModel(
        message: json["message"],
        status: json["status"],
        result: List<StoreItemModel>.from(
            json["dataList"].map((x) => StoreItemModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "dataList": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class StoreItemModel {
  int storeId;
  String storeCode;
  String name;

  StoreItemModel({
    required this.storeId,
    required this.storeCode,
    required this.name,
  });

  factory StoreItemModel.fromRawJson(String str) =>
      StoreItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StoreItemModel.fromJson(Map<String, dynamic> json) => StoreItemModel(
        storeId: json["storeId"]??-1,
        storeCode: json["storeCode"]??"",
        name: json["name"]??"NA",
      );

  Map<String, dynamic> toJson() => {
        "storeId": storeId,
        "storeCode": storeCode,
        "name": name,
      };
}
