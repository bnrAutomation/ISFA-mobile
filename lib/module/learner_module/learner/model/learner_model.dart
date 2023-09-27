import 'dart:convert';

class LearnerResponseModel {
  final String message;
  final int status;
  final List<LearnerCategoryModel> dataList;

  LearnerResponseModel({
    required this.message,
    required this.status,
    required this.dataList,
  });

  factory LearnerResponseModel.fromRawJson(String str) =>
      LearnerResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LearnerResponseModel.fromJson(Map<String, dynamic> json) =>
      LearnerResponseModel(
        message: json["message"],
        status: json["status"],
        dataList: List<LearnerCategoryModel>.from(
            json["dataList"].map((x) => LearnerCategoryModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "dataList": List<dynamic>.from(dataList.map((x) => x.toJson())),
      };
}

class LearnerCategoryModel {
  final String uuid;
  final String categoryName;
  final List<LearnerTopicModel> topicResponseList;

  LearnerCategoryModel({
    required this.uuid,
    required this.categoryName,
    required this.topicResponseList,
  });

  factory LearnerCategoryModel.fromRawJson(String str) =>
      LearnerCategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LearnerCategoryModel.fromJson(Map<String, dynamic> json) =>
      LearnerCategoryModel(
        uuid: json["uuid"],
        categoryName: json["categoryName"],
        topicResponseList: List<LearnerTopicModel>.from(
            json["topicResponseList"]
                .map((x) => LearnerTopicModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "categoryName": categoryName,
        "topicResponseList":
            List<dynamic>.from(topicResponseList.map((x) => x.toJson())),
      };
}

class LearnerTopicModel {
  final String uuid;
  final String topicName;
  final String topicDesc;
  final LearnerTopicType topicType;
  final String fileUrl;
  final List<String>? roles;
  final List<String>? tags;

  LearnerTopicModel({
    required this.uuid,
    required this.topicName,
    required this.topicDesc,
    required this.topicType,
    required this.fileUrl,
    this.roles,
    this.tags,
  });

  factory LearnerTopicModel.fromRawJson(String str) =>
      LearnerTopicModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LearnerTopicModel.fromJson(Map<String, dynamic> json) =>
      LearnerTopicModel(
        uuid: json["uuid"],
        topicName: json["topicName"],
        topicDesc: json["topicDesc"],
        topicType:
            topicTypeValues.map[json["topicType"]] ?? LearnerTopicType.document,
        fileUrl: json["fileUrl"],
        roles: json["roles"] == null
            ? []
            : List<String>.from(json["roles"]!.map((x) => x)),
        tags: json["tags"] == null
            ? []
            : List<String>.from(json["tags"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "topicName": topicName,
        "topicDesc": topicDesc,
        "topicType": topicTypeValues.reverse[topicType],
        "fileUrl": fileUrl,
        "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
      };
}

enum LearnerTopicType { document, image, video }

final topicTypeValues = EnumValues({
  "Documnet": LearnerTopicType.document,
  "image": LearnerTopicType.image,
  "Image": LearnerTopicType.image,
  "Video": LearnerTopicType.video
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
