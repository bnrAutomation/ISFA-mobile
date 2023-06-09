import 'dart:convert';

class FeedbackModel {
  FeedbackModel({
    required this.message,
    required this.status,
    required this.dataList,
  });
  late final String message;
  late final String status;
  late final List<FeedbackDataList> dataList;

  factory FeedbackModel.fromRawJson(String str) =>
      FeedbackModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  FeedbackModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    dataList = List.from(json['dataList'])
        .map((e) => FeedbackDataList.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['dataList'] = dataList.map((e) => e.toJson()).toList();
    return data;
  }
}

class FeedbackDataList {
  FeedbackDataList({
    required this.id,
    required this.purposeId,
    required this.reason,
    required this.imageUrl,
    required this.purposeName,
  });
  late final int id;
  late final int purposeId;
  late final String reason;
  late final String imageUrl;
  late final String purposeName;

  FeedbackDataList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    purposeId = json['purposeId'];
    reason = json['reason'];
    imageUrl = json['imageUrl'];
    purposeName = json['purposeName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['purposeId'] = purposeId;
    data['reason'] = reason;
    data['imageUrl'] = imageUrl;
    data['purposeName'] = purposeName;
    return data;
  }
}
