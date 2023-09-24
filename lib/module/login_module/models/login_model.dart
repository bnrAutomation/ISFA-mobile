import 'dart:convert';

class LoginModel {
  LoginModel({
    required this.message,
    required this.status,
  });
  late final String message;
  late final int status;

  factory LoginModel.fromRawJson(String str) =>
      LoginModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  LoginModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() => {'message': message, 'status': status};
}
