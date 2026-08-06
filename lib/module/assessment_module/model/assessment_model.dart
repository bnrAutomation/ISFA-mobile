import 'dart:convert';

class AssessmentListItemModel {
  final String uuid;
  final String name;
  final String status;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String tags;
  final int noOfAttempts;
  final String canViewSubmission;
  final String canEditSubmission;
  final String canCreateSubmission;

  AssessmentListItemModel(
      {required this.uuid,
      required this.name,
      required this.status,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.tags,
      required this.canViewSubmission,
      required this.canEditSubmission,
      required this.canCreateSubmission,
      required this.noOfAttempts});

  factory AssessmentListItemModel.fromRawJson(String str) =>
      AssessmentListItemModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AssessmentListItemModel.fromJson(Map<String, dynamic> json) =>
      AssessmentListItemModel(
          uuid: json["uuid"],
          name: json["name"],
          status: json["status"],
          description: json["description"],
          startDate: DateTime.parse(json["startDate"]),
          endDate: DateTime.parse(json["endDate"]),
          tags: json["tags"],
          canViewSubmission: json["canViewSubmission"],
          canEditSubmission: json["canEditSubmission"],
          canCreateSubmission: json["canCreateSubmission"],
          noOfAttempts: json["noOfAttempts"] ?? 1);

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "name": name,
        "status": status,
        "description": description,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "tags": tags,
        "canViewSubmission": canViewSubmission,
        "canEditSubmission": canEditSubmission,
        "canCreateSubmission": canCreateSubmission,
        "noOfAttempts": noOfAttempts
      };

  bool isNegative() {
    DateTime endDate = DateTime(
        this.endDate.year, this.endDate.month, this.endDate.day, 23, 59);
    Duration diff = endDate.difference(DateTime.now());

    if (diff.inDays > 0) {
      return false;
    }
    if (diff.inHours > 0) {
      return false;
    }
    if (diff.inMinutes > 0) {
      return false;
    }

    return true;
  }
}

class AssessmentLevel {
  AssessmentLevel(
      {required this.uuid,
      required this.name,
      required this.score,
      required this.givenAttempts,
      required this.status,
      required this.isUnlocked,
      required this.levelOrder});
  late final String uuid;
  late final String name;
  late final int score;
  late final int givenAttempts;
  late final int totalAttempts;
  late final bool status;
  late final bool isUnlocked;
  late final int levelOrder;
  late final int timeLimit;

  AssessmentLevel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    name = json['name'];
    score = json['score'] ?? 0;
    givenAttempts = json['givenAttempts'] ?? 0;
    totalAttempts = json['totalAttempts'] ?? 0;
    status = json['status'] == null ? false : json['status'] == "PASS";
    isUnlocked = json['isUnlocked'] ?? true;
    levelOrder = json["level_order"] ?? 0;
    timeLimit = json['time_limit'] ?? 5;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['name'] = name;
    data['score'] = score;
    data['givenAttempts'] = givenAttempts;
    data['totalAttempts'] = totalAttempts;
    data['status'] = status;
    data['isUnlocked'] = isUnlocked;
    data["level_order"] = levelOrder;
    data["time_limit"] = timeLimit;
    return data;
  }
}

class AssessmentResponse {
  AssessmentResponse({
    required this.totalQuestionAttempted,
    required this.rightAnswers,
    required this.wrongAnswers,
    required this.unattemptedQuestions,
    required this.isQualifiedForCurrentLevel,
    required this.isCurrentLevelUnlocked,
    required this.marksScored,
    required this.attemptsLeft,
    required this.isNextLevelUnlocked,
    required this.totalQuestions,
    required this.maximumMarks,
  });
  late final int totalQuestionAttempted;
  late final int rightAnswers;
  late final int wrongAnswers;
  late final int unattemptedQuestions;
  late final bool isQualifiedForCurrentLevel;
  late final bool isCurrentLevelUnlocked;
  late final int marksScored;
  late final int attemptsLeft;
  late final bool isNextLevelUnlocked;
  late final int totalQuestions;
  late final int maximumMarks;

  factory AssessmentResponse.fromRawJson(String str) =>
      AssessmentResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  AssessmentResponse.fromJson(Map<String, dynamic> json) {
    totalQuestionAttempted = json['totalQuestionAttempted'];
    rightAnswers = json['rightAnswers'];
    wrongAnswers = json['wrongAnswers'];
    unattemptedQuestions = json['unattemptedQuestions'];
    isQualifiedForCurrentLevel = json['isQualifiedForCurrentLevel'];
    isCurrentLevelUnlocked = json['isCurrentLevelUnlocked'] ?? false;
    marksScored = json['marksScored'];
    attemptsLeft = json['attemptsLeft'];
    isNextLevelUnlocked = json['isNextLevelUnlocked'];
    totalQuestions = json['totalQuestions'];
    maximumMarks = json['maximumMarks'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['totalQuestionAttempted'] = totalQuestionAttempted;
    data['rightAnswers'] = rightAnswers;
    data['wrongAnswers'] = wrongAnswers;
    data['unattemptedQuestions'] = unattemptedQuestions;
    data['isQualifiedForCurrentLevel'] = isQualifiedForCurrentLevel;
    data['isCurrentLevelUnlocked'] = isCurrentLevelUnlocked;
    data['marksScored'] = marksScored;
    data['attemptsLeft'] = attemptsLeft;
    data['isNextLevelUnlocked'] = isNextLevelUnlocked;
    data['totalQuestions'] = totalQuestions;
    data['maximumMarks'] = maximumMarks;
    return data;
  }
}
