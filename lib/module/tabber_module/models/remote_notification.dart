import 'dart:convert';

class AppRemoteNotification {
  AppRemoteNotification({
    required this.title,
    required this.body,
  });
  late final String title;
  late final String body;

  factory AppRemoteNotification.fromRawJson(String str) =>
      AppRemoteNotification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  AppRemoteNotification.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    return data;
  }
}
