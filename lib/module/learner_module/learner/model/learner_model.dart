import 'dart:convert';

class LearnerModel {
  LearnerModel({
    required this.dataList,
    required this.message,
    required this.status,
  });
  late final List<LearnerDataList> dataList;
  late final String message;
  late final int status;
  factory LearnerModel.fromRawJson(String str) =>
      LearnerModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  LearnerModel.fromJson(Map<String, dynamic> json) {
    dataList = List.from(json['dataList'])
        .map((e) => LearnerDataList.fromJson(e))
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

class LearnerDataList {
  LearnerDataList({
    required this.title,
    required this.link,
    required this.clientId,
    required this.contentType
  });
  final String title;
  final String link;
  final String clientId;
  final String contentType;

  factory LearnerDataList.fromJson(Map<String, dynamic> json) =>
      LearnerDataList(
        title: json['title'],
        link: json['link'],
        clientId: json['clientId'],
        contentType:json["contentType"]??"doc"
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['link'] = link;
    data['clientId'] = clientId;
    data["contentType"]=contentType;

    return data;
  }
}
