import 'dart:convert';

class AllCampaignModel {
  final String uuid;
  final String name;
  final String status;
  final String imageUrl;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdDate;
  final String tags;
  final String canViewSubmission;
  final String canEditSubmission;
  final String canCreateSubmission;
  final bool isAutoFill;

  AllCampaignModel({
    required this.uuid,
    required this.name,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdDate,
    required this.tags,
    required this.canViewSubmission,
    required this.canEditSubmission,
    required this.canCreateSubmission,
    this.isAutoFill = false,
  });

  factory AllCampaignModel.fromRawJson(String str) =>
      AllCampaignModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AllCampaignModel.fromJson(Map<String, dynamic> json) =>
      AllCampaignModel(
        uuid: json["uuid"] ?? "",
        name: json["name"] ?? "",
        status: json["status"] ?? "",
        imageUrl: json["imageUrl"] ?? "",
        description: json["description"] ?? "",
        startDate: DateTime.parse(json["startDate"]),
        endDate: DateTime.parse(json["endDate"]),
        createdDate :DateTime.parse(json["createdDate"]),
        tags: json["tags"] ?? "",
        canViewSubmission: json["canViewSubmission"],
        canEditSubmission: json["canEditSubmission"],
        canCreateSubmission: json["canCreateSubmission"],
        isAutoFill: json["isAutoFill"] == true,
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "name": name,
        "status": status,
        "imageUrl": imageUrl,
        "description": description,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "createdDate":createdDate.toIso8601String(),
        "tags": tags,
        "canViewSubmission": canViewSubmission,
        "canEditSubmission": canEditSubmission,
        "canCreateSubmission": canCreateSubmission,
        "isAutoFill": isAutoFill,
      };

  bool isNegative() {
    DateTime endDate = DateTime(
        this.endDate.year, this.endDate.month, this.endDate.day, 23, 59);
    Duration diff =
        //DateTime.now().difference(endDate);

        endDate.difference(DateTime.now());

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
