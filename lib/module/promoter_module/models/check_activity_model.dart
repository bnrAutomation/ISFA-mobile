import 'dart:convert';

class ChackActivityModel {
  ChackActivityModel({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.activityData,
  });
  late final String status;
  late final int statusCode;
  late final String message;
  late final CheckActivityData activityData;

  factory ChackActivityModel.fromRawJson(String str) =>
      ChackActivityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
  
  ChackActivityModel.fromJson(Map<String, dynamic> json){
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    activityData = CheckActivityData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['statusCode'] = statusCode;
    data['message'] = message;
    data['data'] = activityData.toJson();
    return data;
  }
}

class CheckActivityData {
  CheckActivityData({
    required this.campaignResponseSubmitted,
    required this.salesLog,
    required this.inventoryAdd,
    required this.redirect
  });
  late final bool campaignResponseSubmitted;
  late final bool salesLog;
  late final bool inventoryAdd;
  late final bool redirect;
  
  CheckActivityData.fromJson(Map<String, dynamic> json){
    campaignResponseSubmitted = json['campaignResponseSubmitted'];
    salesLog = json['salesLog'];
    inventoryAdd = json['inventoryAdd'];
    redirect=json["redirect"];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['campaignResponseSubmitted'] = campaignResponseSubmitted;
    data['salesLog'] = salesLog;
    data['inventoryAdd'] = inventoryAdd;
    data["redirect"]=redirect;
    return data;
  }
}