import 'dart:convert';

class FeedbackPorposeModel {
  FeedbackPorposeModel({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory FeedbackPorposeModel.fromRawJson(String str) =>
      FeedbackPorposeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FeedbackPorposeModel.fromJson(Map<String, dynamic> json) =>
      FeedbackPorposeModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
