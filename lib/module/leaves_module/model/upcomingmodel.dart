import 'package:i_densfa/utility/extensions.dart';

class UpcomingModel {
  UpcomingModel({
    required this.date,
    required this.name,
  });
  late final DateTime? date;
  late final String name;

  UpcomingModel.fromJson(Map<String, dynamic> json) {
    date = json['date'] != null ? DateTime.parse(json["date"]) : null;
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date?.toStringFormat('yyyy-MM-dd');
    data['name'] = name;
    return data;
  }
}

class WeekOffModel {
  WeekOffModel({
    required this.dateFrom,
    required this.dateTo,
    required this.dayId,
    required this.remark,
    required this.userId,
  });
  late final DateTime? dateFrom;
  late final DateTime? dateTo;
  late final int dayId;
  late final String remark;
  late final String userId;

  WeekOffModel.fromJson(Map<String, dynamic> json) {
    dateFrom =
        json['dateFrom'] != null ? DateTime.parse(json["dateFrom"]) : null;

    dateTo = json['dateTo'] != null ? DateTime.parse(json["dateTo"]) : null;
    dayId = json['dayId'] ?? -1;
    remark = json['remark'] ?? "";
    userId = json['userId'] ?? "-1";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dateFrom'] = dateFrom?.toStringFormat('yyyy-MM-dd');

    data['dateTo'] = dateTo?.toStringFormat('yyyy-MM-dd');

    data['dayId'] = dayId;
    data['remark'] = remark;
    data['userId'] = userId;
    return data;
  }
}
