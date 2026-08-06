import 'dart:convert';

import 'get_all_questions_model.dart';

List<GetAllSectionsModel> getAllSectionsModelFromJson(String str) =>
    List<GetAllSectionsModel>.from(
        json.decode(str).map((x) => GetAllSectionsModel.fromJson(x)));

String getAllSectionsModelToJson(List<GetAllSectionsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllSectionsModel {
  String uuid;
  String name;
  String description;
  int priorityOrder;
  List<GetQuestionsModel> selectedSectionQuestions = [];

  GetAllSectionsModel({
    required this.uuid,
    required this.name,
    required this.description,
    required this.priorityOrder,
  });

  factory GetAllSectionsModel.fromJson(Map<String, dynamic> json) =>
      GetAllSectionsModel(
        uuid: json["uuid"] ?? "",
        name: json["name"] ?? "",
        description: json["description"] ?? "",
        priorityOrder: json["priorityOrder"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "name": name,
        "description": description,
        "priorityOrder": priorityOrder,
      };
}
