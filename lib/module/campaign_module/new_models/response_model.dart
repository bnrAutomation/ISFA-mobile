import 'dart:convert';

class ResponseModel {
  factory ResponseModel.fromRawJson(String str) =>
      ResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  late final String message;
  late final String uuId;

  ResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? "";
    uuId = json['uuId'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['uuId'] = uuId;
    return data;
  }
}


class ProductInfo {
  late final String productSeries;
  List<String>? packSizes;
  late final String internalName;

   factory ProductInfo.fromRawJson(String str) =>
      ProductInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  ProductInfo({required this.productSeries, this.packSizes});

  ProductInfo.fromJson(Map<String, dynamic> json) {
    productSeries = json['productSeries']??"";
    internalName = json["internalName"]??"";
    final sizes = json['packSizes'];
    if (sizes is List) {
      packSizes = sizes.map((e) => e.toString()).toList();
    } else {
      packSizes = <String>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['productSeries'] = productSeries;
    data['internalName']= internalName;
    data['packSizes'] = packSizes;
    return data;
  }
}