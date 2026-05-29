import 'dart:convert';

class SurveyListItemModel {
  final String uuid;
  final String name;
  final String status;
  final String imageUrl;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String tags;
  final String canViewSubmission;
  final String canEditSubmission;
  final String canCreateSubmission;
  final bool editable;

  SurveyListItemModel({
    required this.uuid,
    required this.name,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.tags,
    required this.canViewSubmission,
    required this.canEditSubmission,
    required this.canCreateSubmission,
    required this.editable,
  });

  factory SurveyListItemModel.fromRawJson(String str) =>
      SurveyListItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SurveyListItemModel.fromJson(Map<String, dynamic> json) =>
      SurveyListItemModel(
        uuid: json["uuid"],
        name: json["name"],
        status: json["status"],
        imageUrl: json["imageUrl"],
        description: json["description"],
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        tags: json["tags"],
        canViewSubmission: json["canViewSubmission"],
        canEditSubmission: json["canEditSubmission"],
        canCreateSubmission: json["canCreateSubmission"],
        editable: json["editable"],
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "name": name,
        "status": status,
        "imageUrl": imageUrl,
        "description": description,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "tags": tags,
        "canViewSubmission": canViewSubmission,
        "canEditSubmission": canEditSubmission,
        "canCreateSubmission": canCreateSubmission,
        "editable": editable
      };

  bool isNagative() {
    DateTime endDate = DateTime(
        this.endDate.year, this.endDate.month, this.endDate.day, 23, 59);
    Duration diff = endDate.difference(DateTime.now());

    if (diff.inDays > 0) {
      return false;
    }
    if (diff.inHours > 0) {
      return false;
    }
    if (diff.inMinutes > 0) {
      return false;
    }

    return true;
  }
}

class SurveyDetailModel {
  SurveyDetailModel({
    required this.targetedStores,
    required this.includedStores,
    required this.totalResponse,
  });

  int targetedStores;
  int includedStores;
  int totalResponse;

  factory SurveyDetailModel.fromRawJson(String str) =>
      SurveyDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SurveyDetailModel.fromJson(Map<String, dynamic> json) =>
      SurveyDetailModel(
          includedStores: json["includedStores"],
          targetedStores: json["targetedStores"],
          totalResponse: json["totalResponse"] ?? 0);

  Map<String, dynamic> toJson() => {
        "totalResponse": totalResponse,
        "includedStores": includedStores,
        "targetedStores": targetedStores,
      };
}

class SavedQuestion {
  final String questionUuid;
  final String answer;

  SavedQuestion({required this.questionUuid, required this.answer});

  factory SavedQuestion.fromJson(Map<String, dynamic> json) {
    return SavedQuestion(
      questionUuid: json['uuid'] ?? "",
      answer: json['answer'] ?? "",
    );
  }
}

class OptionList {
  OptionList({
    required this.data,
    required this.message,
    required this.status,
  });
  late final List<String> data;
  late final String message;
  late final String status;

  factory OptionList.fromRawJson(String str) =>
      OptionList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  OptionList.fromJson(Map<String, dynamic> json) {
    data = (json['data'] ?? []).cast<String>();
    message = json['message'] ?? "";
    status = json['status'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['data'] = data;
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}
