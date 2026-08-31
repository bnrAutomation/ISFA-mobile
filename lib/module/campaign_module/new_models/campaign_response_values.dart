class CampaignResponseQuestionValue {
  final String questionUuid;
  final String? questionName;
  final String? questionDataType;
  final String? answer;
  final bool issue;
  final String? issuesImage;
  final String? issuesRemarks;

  CampaignResponseQuestionValue({
    required this.questionUuid,
    this.questionName,
    this.questionDataType,
    this.answer,
    this.issue = false,
    this.issuesImage,
    this.issuesRemarks,
  });

  factory CampaignResponseQuestionValue.fromJson(Map<String, dynamic> json) {
    return CampaignResponseQuestionValue(
      questionUuid: json['questionUuid']?.toString() ?? '',
      questionName: json['questionName']?.toString(),
      questionDataType: json['questionDataType']?.toString(),
      answer: json['answer']?.toString(),
      issue: json['issue'] == true,
      issuesImage: json['issuesImage']?.toString(),
      issuesRemarks:
          (json['issuesRemarks'] ?? json['issuesRemark'])?.toString(),
    );
  }
}

class CampaignResponseSectionValue {
  final String sectionUuid;
  final String? sectionName;
  final List<CampaignResponseQuestionValue> questions;

  CampaignResponseSectionValue({
    required this.sectionUuid,
    this.sectionName,
    required this.questions,
  });

  factory CampaignResponseSectionValue.fromJson(Map<String, dynamic> json) {
    return CampaignResponseSectionValue(
      sectionUuid: json['sectionUuid']?.toString() ?? '',
      sectionName: json['sectionName']?.toString(),
      questions: (json['questions'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CampaignResponseQuestionValue.fromJson(
              Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// One saved campaign response submission from response-values API.
/// New shape: `{ "responseValues": [sections...], "createdDate": "yyyy-MM-dd" }`
class CampaignResponseValuesSubmission {
  final String? createdDate;
  final List<CampaignResponseSectionValue> responseValues;

  CampaignResponseValuesSubmission({
    this.createdDate,
    required this.responseValues,
  });

  factory CampaignResponseValuesSubmission.fromJson(Map<String, dynamic> json) {
    return CampaignResponseValuesSubmission(
      createdDate: json['createdDate']?.toString(),
      responseValues: (json['responseValues'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CampaignResponseSectionValue.fromJson(
              Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// Section fill status from response-values (Outlet Onboarding filtering).
class CampaignSectionFillStatus {
  final int? sectionId;
  final String sectionUuid;
  final bool filled;

  CampaignSectionFillStatus({
    this.sectionId,
    required this.sectionUuid,
    required this.filled,
  });

  factory CampaignSectionFillStatus.fromJson(Map<String, dynamic> json) {
    return CampaignSectionFillStatus(
      sectionId: json['sectionId'] is int
          ? json['sectionId'] as int
          : int.tryParse(json['sectionId']?.toString() ?? ''),
      sectionUuid: json['sectionUuid']?.toString() ?? '',
      filled: json['filled'] == true,
    );
  }
}

/// Parses response-values into submission wrappers.
/// Supports:
/// - New: `[{ responseValues: [sections], createdDate }]`
/// - Old: `[[{section}]]` or `[{section}]` (wrapped as submissions without date)
List<CampaignResponseValuesSubmission> parseCampaignResponseValuesSubmissions(
    dynamic decoded) {
  final submissions = <CampaignResponseValuesSubmission>[];

  void addItem(dynamic e) {
    if (e is Map) {
      final map = Map<String, dynamic>.from(e);

      // New wrapper shape.
      if (map.containsKey('responseValues')) {
        submissions.add(CampaignResponseValuesSubmission.fromJson(map));
        return;
      }

      // Skip fill-status-only records (no questions payload).
      if (map.containsKey('filled') && !map.containsKey('questions')) {
        return;
      }

      // Legacy: section object at top level / nested list.
      if (map.containsKey('sectionUuid') || map.containsKey('questions')) {
        submissions.add(CampaignResponseValuesSubmission(
          createdDate: map['createdDate']?.toString(),
          responseValues: [CampaignResponseSectionValue.fromJson(map)],
        ));
      }
    } else if (e is List) {
      // Nested list of sections without a wrapper → one submission.
      final sections = <CampaignResponseSectionValue>[];
      String? createdDate;

      void collectSections(dynamic item) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (map.containsKey('responseValues')) {
            submissions.add(CampaignResponseValuesSubmission.fromJson(map));
            return;
          }
          if (map.containsKey('filled') && !map.containsKey('questions')) {
            return;
          }
          if (map.containsKey('sectionUuid') || map.containsKey('questions')) {
            createdDate ??= map['createdDate']?.toString();
            sections.add(CampaignResponseSectionValue.fromJson(map));
          }
        } else if (item is List) {
          for (final inner in item) {
            collectSections(inner);
          }
        }
      }

      for (final inner in e) {
        collectSections(inner);
      }
      if (sections.isNotEmpty) {
        submissions.add(CampaignResponseValuesSubmission(
          createdDate: createdDate,
          responseValues: sections,
        ));
      }
    }
  }

  if (decoded is List) {
    for (final e in decoded) {
      addItem(e);
    }
  } else if (decoded is Map) {
    addItem(decoded);
  }
  return submissions;
}

/// Flat section list for callers that do not need createdDate.
/// Prefer [parseCampaignResponseValuesSubmissions] when date filtering is needed.
List<CampaignResponseSectionValue> parseCampaignResponseValues(dynamic decoded) {
  return parseCampaignResponseValuesSubmissions(decoded)
      .expand((s) => s.responseValues)
      .toList();
}

/// Parses section fill-status payload, e.g. `[{sectionUuid, filled}]`.
List<CampaignSectionFillStatus> parseCampaignSectionFillStatuses(
    dynamic decoded) {
  final statuses = <CampaignSectionFillStatus>[];

  void addStatus(dynamic e) {
    if (e is Map) {
      final map = Map<String, dynamic>.from(e);
      if (!map.containsKey('filled')) return;
      statuses.add(CampaignSectionFillStatus.fromJson(map));
    } else if (e is List) {
      for (final inner in e) {
        addStatus(inner);
      }
    }
  }

  if (decoded is List) {
    for (final e in decoded) {
      addStatus(e);
    }
  }
  return statuses;
}
