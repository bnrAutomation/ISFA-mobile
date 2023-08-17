import 'dart:convert';

class AnalyticsModel {
  final int target;
  final int achieved;
  final double percentage;
  final String kpiName;

  AnalyticsModel({
    required this.target,
    required this.achieved,
    required this.percentage,
    required this.kpiName,
  });

  factory AnalyticsModel.fromRawJson(String str) =>
      AnalyticsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) => AnalyticsModel(
        target: json["target"],
        achieved: json["achieved"],
        percentage: json["percentage"],
        kpiName: json["kpiName"],
      );

  Map<String, dynamic> toJson() => {
        "target": target,
        "achieved": achieved,
        "percentage": percentage,
        "kpiName": kpiName,
      };
}
