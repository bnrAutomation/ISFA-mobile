import 'dart:convert';

import 'package:i_densfa/module/campaign_module/new_models/question.dart';

class SagmentRequest {
  SagmentRequest({
    required this.groupname,
    required this.sectionUuid,
    required this.campaignUuid,
    required this.group,
    // required this.storeId,
  });
  late final String groupname;
  late final String sectionUuid;
  late final String campaignUuid;
  // late final String storeId;
  late final List<CampaignQuestionModel> group;

  factory SagmentRequest.fromRawJson(String str) =>
      SagmentRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  SagmentRequest.fromJson(Map<String, dynamic> json) {
    groupname = json['groupname'];
    sectionUuid = json['sectionUuid'];
    campaignUuid = json['campaignUuid'];
    // storeId = json["storeId"];
    group = List.from(json['group'])
        .map((e) => CampaignQuestionModel.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['groupname'] = groupname;
    data['sectionUuid'] = sectionUuid;
    data['campaignUuid'] = campaignUuid;
    data['group'] = group.map((e) => e.toJson()).toList();
    return data;
  }
}
