import 'dart:convert';

class NotificationResponseModel {
  final int statusCode;
  final String message;
  final List<NotificationModel> notifications;

  NotificationResponseModel({
    required this.statusCode,
    required this.message,
    required this.notifications,
  });

  factory NotificationResponseModel.fromRawJson(String str) =>
      NotificationResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) =>
      NotificationResponseModel(
        statusCode: json["statusCode"],
        message: json["message"],
        notifications: List<NotificationModel>.from(
            json["notifications"].map((x) => NotificationModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "message": message,
        "notifications":
            List<dynamic>.from(notifications.map((x) => x.toJson())),
      };
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String notificationType;
  final String createdBy;
  final DateTime createdDate;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.createdBy,
    required this.createdDate,
  });

  factory NotificationModel.fromRawJson(String str) =>
      NotificationModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        notificationType: json["notificationType"],
        createdBy: json["createdBy"],
        createdDate: DateTime.parse(json["createdDate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
        "notificationType": notificationType,
        "createdBy": createdBy,
        "createdDate": createdDate.toIso8601String(),
      };
}
