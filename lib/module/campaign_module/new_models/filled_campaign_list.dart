import 'dart:convert';

class FilledCampaignList {
  FilledCampaignList({
    required this.userCampaignResponses,
  });
  late final List<String> userCampaignResponses;

  factory FilledCampaignList.fromRawJson(String str) =>
      FilledCampaignList.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  FilledCampaignList.fromJson(Map<String, dynamic> json) {
    userCampaignResponses =
        List.castFrom<dynamic, String>(json['userCampaignResponses'] ?? []);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userCampaignResponses'] = userCampaignResponses;
    return data;
  }
}
