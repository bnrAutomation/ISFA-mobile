import 'dart:convert';

class ForgotPasswordModel {
  ForgotPasswordModel({
    required this.message,
    required this.status,
    required this.forgotPassword,
  });
  late final String message;
  late final String status;
  late final ForgotPasswordData forgotPassword;

  factory ForgotPasswordModel.fromRawJson(String str) =>
      ForgotPasswordModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    forgotPassword = ForgotPasswordData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['data'] = forgotPassword.toJson();
    return data;
  }
}

class ForgotPasswordData {
  ForgotPasswordData({
    required this.message,
  });
  late final String message;

  ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    return data;
  }
}
