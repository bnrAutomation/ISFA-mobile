import 'dart:convert';

class IssuesTicketModelContent {
  IssuesTicketModelContent(
      {required this.content,
      required this.totalPages,
      required this.pageable});
  late final List<IssuesTicketModel> content;
  late final int totalPages;
  late final Pageable pageable;
  factory IssuesTicketModelContent.fromRawJson(String str) =>
      IssuesTicketModelContent.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  IssuesTicketModelContent.fromJson(Map<String, dynamic> json) {
    totalPages = json['totalPages'] ?? 0;
    content = List.from(json['content'] ?? [])
        .map((e) => IssuesTicketModel.fromJson(e))
        .toList();
    pageable = Pageable.fromJson(json['pageable']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['content'] = content.map((e) => e.toJson()).toList();
    data['totalPages'] = totalPages;
    return data;
  }
}

List<IssuesTicketModel> issuesTicketModelFromJson(String str) =>
    List<IssuesTicketModel>.from(
        json.decode(str).map((x) => IssuesTicketModel.fromJson(x)));

String issuesTicketModelToJson(List<IssuesTicketModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IssuesTicketModel {
  IssuesTicketModel(
      {required this.id,
      required this.status,
      required this.ticketNo,
      required this.storeId,
      required this.storeName,
      required this.issueCategory,
      required this.issueSubCategory,
      required this.assignedTo,
      required this.ticketDate,
      required this.dueDate,
      required this.responseTatExceedDays,
      required this.resolutionTatExceed,
      required this.responseUuid,
      required this.question,
      required this.questionUuid,
      required this.beforeImage,
      required this.campaignUuid});
  late final int id;
  late final String status;
  late final int ticketNo;
  late final int storeId;
  late final String storeName;
  late final String storeCode;
  late final String issueCategory;
  late final String issueSubCategory;
  late final String assignedTo;
  late final DateTime? ticketDate;
  late final DateTime? auditDate;
  late final DateTime? dueDate;
  late final int responseTatExceedDays;
  late final int resolutionTatExceed;
  late final String responseUuid;
  late final String question;
  late final String questionUuid;
  late String? afterImage;
  late String? beforeImage;
  late bool selected;
  late final String campaignUuid;
  late String reopenAfterImage;
  late String reopenBeforeImage;
  late bool hasReopen;

  IssuesTicketModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'] ?? "Open";
    ticketNo = json['ticketNo'];
    storeId = json['storeId'];
    storeCode = json['storeCode'] ?? "NA";
    storeName = json['storeName'] ?? "";
    issueCategory = json['issueCategory'];
    issueSubCategory = json['issueSubCategory'];
    assignedTo = json['assignedTo'] ?? "";
    ticketDate = json['ticketDate'] == null
        ? null
        : json['ticketDate'] == "N/A"
            ? null
            : DateTime.parse(json['ticketDate']);
    auditDate = json['auditDate'] == null
        ? null
        : json['auditDate'] == "N/A"
            ? null
            : DateTime.parse(json['auditDate']);
    dueDate = json['dueDate'] == null
        ? null
        : json['dueDate'] == "N/A"
            ? null
            : DateTime.parse(json['dueDate']);
    responseTatExceedDays = json['responseTatExceedDays'] ?? 0;
    resolutionTatExceed = json['resolutionTatExceed'] ?? 0;
    responseUuid = json['responseUuid'] ?? "";
    question = json['question'] ?? "";
    questionUuid = json['questionUuid'];
    afterImage = json['afterImage'];
    beforeImage = json['beforeImage'];
    selected = json['selected'] ?? false;
    campaignUuid = json['campaignUuid'] ?? "";
    hasReopen = json['hasReopen'] ?? false;
    reopenBeforeImage = json['reopenBeforeImage'] ?? "";
    reopenAfterImage = json['reopenAfterImage'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['ticketNo'] = ticketNo;
    data['storeCode'] = storeCode;
    data['storeId'] = storeId;
    data['storeName'] = storeName;
    data['issueCategory'] = issueCategory;
    data['issueSubCategory'] = issueSubCategory;
    data['assignedTo'] = assignedTo;
    data['ticketDate'] = ticketDate;
    data['dueDate'] = dueDate;
    data['responseTatExceedDays'] = responseTatExceedDays;
    data['resolutionTatExceed'] = resolutionTatExceed;
    data['responseUuid'] = responseUuid;
    data['question'] = question;
    data['questionUuid'] = questionUuid;
    data['afterImage'] = afterImage;
    data['beforeImage'] = beforeImage;
    data['selected'] = selected;
    data['campaignUuid'] = campaignUuid;
    data['hasReopen'] = hasReopen;
    data['reopenBeforeImage'] = reopenBeforeImage;
    data['reopenAfterImage'] = reopenAfterImage;
    return data;
  }
}

class Pageable {
  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });
  late final int pageNumber;
  late final int pageSize;
  late final int offset;
  late final bool paged;
  late final bool unpaged;

  Pageable.fromJson(Map<String, dynamic> json) {
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    offset = json['offset'];
    paged = json['paged'];
    unpaged = json['unpaged'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['pageNumber'] = pageNumber;
    data['pageSize'] = pageSize;
    data['offset'] = offset;
    data['paged'] = paged;
    data['unpaged'] = unpaged;
    return data;
  }
}
