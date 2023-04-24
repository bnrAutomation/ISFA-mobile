import 'dart:convert';

class MyActivityModel {
  MyActivityModel({
    required this.dataList,
    required this.message,
    required this.status,
  });
  late final List<MyActivityDataList> dataList;
  late final String message;
  late final String status;

  factory MyActivityModel.fromRawJson(String str) =>
      MyActivityModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  MyActivityModel.fromJson(Map<String, dynamic> json) {
    dataList = List.from(json['dataList'])
        .map((e) => MyActivityDataList.fromJson(e))
        .toList();
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dataList'] = dataList.map((e) => e.toJson()).toList();
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

class MyActivityDataList {
  MyActivityDataList({
    required this.storeName,
    required this.time,
    required this.activityName,
  });
  late final String storeName;
  late final String time;
  late final String activityName;

  MyActivityDataList.fromJson(Map<String, dynamic> json) {
    storeName =
        json['storeName'].toString().isEmpty ? "NA" : json['storeName'] ?? "NA";
    time = json['time'];
    activityName = json['activityName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['storeName'] = storeName;
    data['time'] = time;
    data['activityName'] = activityName;
    return data;
  }
}
