class AnalyticsModel {
  AnalyticsModel({
    required this.name,
    required this.target,
    required this.actual,
  });
  late final String name;
  late final String target;
  late final String actual;

  AnalyticsModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    target = json['target'];
    actual = json['actual'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['target'] = target;
    data['actual'] = actual;
    return data;
  }
}
