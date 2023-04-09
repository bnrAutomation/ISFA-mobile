import 'dart:convert';

class CompaignsModel {
  CompaignsModel({
    required this.storeId,
    required this.activityId,
    required this.fromdate,
    required this.dateCreated,
    required this.campaignId,
    required this.createdBy,
  });

  int storeId;
  int activityId;
  DateTime fromdate;
  DateTime dateCreated;
  int campaignId;
  String createdBy;

  factory CompaignsModel.fromRawJson(String str) =>
      CompaignsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CompaignsModel.fromJson(Map<String, dynamic> json) => CompaignsModel(
        storeId: json["storeId"],
        activityId: json["activity_id"],
        fromdate: DateTime.parse(json["fromdate"]),
        dateCreated: DateTime.parse(json["date_created"]),
        campaignId: json["campaign_id"],
        createdBy: json["created_by"],
      );

  Map<String, dynamic> toJson() => {
        "storeId": storeId,
        "activity_id": activityId,
        "fromdate": fromdate.toIso8601String(),
        "date_created": dateCreated.toIso8601String(),
        "campaign_id": campaignId,
        "created_by": createdBy,
      };
}
