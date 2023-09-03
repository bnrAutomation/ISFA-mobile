import 'dart:convert';

class UserCampaignsModel {
  UserCampaignsModel({
    required this.message,
    required this.status,
    required this.dataList,
  });

  String message;
  String status;
  List<CampaignDetailModel>? dataList;

  factory UserCampaignsModel.fromRawJson(String str) =>
      UserCampaignsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserCampaignsModel.fromJson(Map<String, dynamic> json) =>
      UserCampaignsModel(
        message: json["message"],
        status: json["status"],
        dataList: json["dataList"] == null
            ? []
            : List<CampaignDetailModel>.from(
                json["dataList"].map((x) => CampaignDetailModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "dataList": dataList == null
            ? null
            : List<dynamic>.from(dataList!.map((x) => x.toJson())),
      };
}

class CampaignDetailModel {
  CampaignDetailModel({
    required this.campaignId,
    required this.name,
    required this.description,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.imageName,
    required this.companyId,
    required this.campaignData,
  });

  int campaignId;
  String name;
  String description;
  DateTime startDate;
  String startTime;
  DateTime endDate;
  String endTime;
  String imageName;
  int companyId;
  SavedCampaignDataModel? campaignData;

  factory CampaignDetailModel.fromRawJson(String str) =>
      CampaignDetailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

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

  factory CampaignDetailModel.fromJson(Map<String, dynamic> json) {
    return CampaignDetailModel(
        campaignId: json["campaignId"],
        name: json["name"],
        description: json["description"],
        startDate: DateTime.parse(json["startDate"]),
        startTime: json["startTime"],
        endDate: DateTime.parse(json["endDate"]),
        endTime: json["endTime"],
        imageName: json["imageName"],
        campaignData: json["savedCampaignData"] == null
            ? null
            : SavedCampaignDataModel.fromJson(json["savedCampaignData"]),
        companyId: json["companyId"]);
  }

  Map<String, dynamic> toJson() => {
        "campaignId": campaignId,
        "name": name,
        "description": description,
        "startDate": startDate,
        "startTime": startTime,
        "endDate": endDate,
        "endTime": endTime,
        "imageName": imageName,
        "companyId": companyId,
        "savedCampaignData": campaignData?.toJson()
      };
}

class SavedCampaignDataModel {
  SavedCampaignDataModel({
    required this.targetedStores,
    required this.includedStores,
    required this.totalResponse,
  });

  int targetedStores;
  int includedStores;
  int totalResponse;

  factory SavedCampaignDataModel.fromRawJson(String str) =>
      SavedCampaignDataModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SavedCampaignDataModel.fromJson(Map<String, dynamic> json) =>
      SavedCampaignDataModel(
          includedStores: json["includedStores"],
          targetedStores: json["targetedStores"],
          totalResponse: json["totalResponse"] ?? 0);

  Map<String, dynamic> toJson() => {
        "totalResponse": totalResponse,
        "includedStores": includedStores,
        "targetedStores": targetedStores,
      };
}
