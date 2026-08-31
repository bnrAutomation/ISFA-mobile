import 'dart:convert';

class AuthenticateResponseModel {
  final String accessToken;
  final String tokenType;

  AuthenticateResponseModel({
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthenticateResponseModel.fromRawJson(String str) =>
      AuthenticateResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthenticateResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthenticateResponseModel(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        //tokeExpiry: json["toke_expiry"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "token_type": tokenType,
      };

  String getUserId() {
    final parts = accessToken.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }
    return payloadMap['sub'];
  }
}

class UserDetailsResponseModel {
  final String message;
  final int status;
  final UserInfo data;

  UserDetailsResponseModel({
    required this.message,
    required this.status,
    required this.data,
  });

  factory UserDetailsResponseModel.fromRawJson(String str) =>
      UserDetailsResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      UserDetailsResponseModel(
        message: json["message"],
        status: json["status"],
        data: UserInfo.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "status": status,
        "data": data.toJson(),
      };
}

class UserInfo {
  int id;
  String uuid;
  String email;
  String username;
  String supervisorId;
  int companyId;
  String designation;
  DateTime? lastLogin;
  String reportTo;
  String userStatus;
  String role;
  String mobile;
  String pin;
  String photoUrl;
  List<String> tags;
  String fullName;
  String city;
  String state;
  DateTime createdDate;
  String createdById;
  bool active;
  DateTime doj;
  String companyName;
  Configuration configuration;
  UserConfiguration userConfiguration;
  bool resetpass;
  String userLatLong;

  UserInfo(
      {required this.id,
      required this.uuid,
      required this.email,
      required this.username,
      required this.supervisorId,
      required this.companyId,
      required this.designation,
      required this.lastLogin,
      required this.reportTo,
      required this.userStatus,
      required this.role,
      required this.mobile,
      required this.pin,
      required this.photoUrl,
      required this.tags,
      required this.fullName,
      required this.city,
      required this.state,
      required this.createdDate,
      required this.createdById,
      required this.active,
      required this.doj,
      required this.resetpass,
      required this.userLatLong,
      required this.companyName,
      required this.configuration,
      required this.userConfiguration});

  factory UserInfo.fromRawJson(String str) =>
      UserInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInfo.fromJson(Map<String, dynamic> data) => UserInfo(
      id: data["userId"] ?? "",
      uuid: data["uuid"] ?? "",
      email: data["email"] ?? "",
      username: data["username"] ?? "",
      supervisorId: data["supervisor"] ?? "",
      companyId: data["companyId"] ?? "",
      designation: data["designation"] ?? "",
      lastLogin:
          data["lastLogin"] != null ? DateTime.parse(data["lastLogin"]) : null,
      reportTo: data["reportTo"] ?? "",
      userStatus: data["userStatus"] ?? "",
      role: data["role"] ?? '',
      mobile: data["mobile"] ?? "",
      pin: data["pin"] ?? "",
      photoUrl: data["photourl"] ?? "",
      tags: data["tags"] == null
          ? []
          : List<String>.from(data["tags"].map((x) => x)),
      fullName: data["fullName"] ?? data["username"] ?? "",
      city: data["city"] ?? "",
      state: data["state"] ?? "",
      createdDate: DateTime.parse(data["createdDate"]),
      createdById: data["createdBy"] ?? "",
      active: data["active"] ?? false,
      resetpass: data["resetpass"] ?? false,
      userLatLong: data['userLatLong'] ?? "",
      configuration: data['configuration'] != null
          ? Configuration.fromJson(data['configuration'])
          : Configuration(
             requiredAddMechanic:false,
              requiredAddCampaignBeat:false,
              requiredMultiStore:false,
              requiredDoubleMarkIn:false,
              requiredGstfromRetailer:false,
              requiredFwpStore:false,
              requiredMultiImageInCampaign:false,
              requiresAllFillCampigned: false,
              requiredStartDuty: false,
              requiredSelfieForMarkIn: true,
              requiredSelfieForStartDuty: true,
              requiredGeoFencingForMarkIn: true,
              requiredSelfieForSurvey: true,
              requiredBulkAttendance: true,
              requiredEmailChange: true,
              requiredPhoneChange: true,
              requiredPasswordChange: true,
              requiredClientNameForSurvey: true,
              allowPrefilledQuestion: false),
      userConfiguration: data['userConfiguration'] != null
          ? data['userConfiguration'] is Map
              ? UserConfiguration.fromJson(data['userConfiguration'])
              : UserConfiguration.fromRawJson(data['userConfiguration'])
          : UserConfiguration(
              requiredGeoFenceStartDuty: false,
              requiredApplyLeave: true,
              requiredUpcommingHoliday: true,
              requiredAppliedLeaveRequest: true,
              requiredStartDuty: true),
      doj: DateTime.parse(data["doj"]),
      companyName: data["companyName"] ?? "");

  Map<String, dynamic> toJson() => {
        "userId": id,
        "uuid": uuid,
        "email": email,
        "username": username,
        "supervisor": supervisorId,
        "companyId": companyId,
        "designation": designation,
        "lastLogin": lastLogin?.toIso8601String(),
        "reportTo": reportTo,
        "userStatus": userStatus,
        "role": role,
        "mobile": mobile,
        "pin": pin,
        "photourl": photoUrl,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "fullName": fullName,
        "city": city,
        "state": state,
        "createdDate": createdDate.toIso8601String(),
        "createdBy": createdById,
        "active": active,
        "doj": createdDate.toIso8601String(),
        'configuration': configuration.toJson(),
        "userConfiguration": userConfiguration.toJson(),
        "companyName": companyName,
        "resetpass": resetpass,
        "userLatLong": userLatLong,
      };
}

class UserConfiguration {
  bool requiredApplyLeave;
  bool requiredUpcommingHoliday;
  bool requiredAppliedLeaveRequest;
  bool requiredStartDuty;
  bool requiredGeoFenceStartDuty;

  UserConfiguration(
      {required this.requiredApplyLeave,
      required this.requiredUpcommingHoliday,
      required this.requiredAppliedLeaveRequest,
      required this.requiredStartDuty,
      required this.requiredGeoFenceStartDuty});

  factory UserConfiguration.fromRawJson(String str) =>
      UserConfiguration.fromJson(json.decode(str));

  factory UserConfiguration.fromJson(Map<String, dynamic> json) =>
      UserConfiguration(
          requiredApplyLeave: json['requiredApplyLeave'] ?? false,
          requiredUpcommingHoliday: json['requiredUpcommingHoliday'] ?? true,
          requiredAppliedLeaveRequest: json['requiredAppliedLeaveRequest'] ?? true,
          requiredStartDuty: json["requiredStartDuty"] ?? true,
          requiredGeoFenceStartDuty:
              json['requiredGeoFenceStartDuty'] ?? false);

  Map<String, dynamic> toJson() => {
        'requiredApplyLeave': requiredApplyLeave,
        'requiredUpcommingHoliday': requiredUpcommingHoliday,
        'requiredAppliedLeaveRequest': requiredAppliedLeaveRequest,
        "requiredStartDuty": requiredStartDuty,
        "requiredGeoFenceStartDuty": requiredGeoFenceStartDuty
      };
}

class Configuration {
  bool requiredStartDuty;
  bool requiredSelfieForStartDuty;
  bool requiredSelfieForMarkIn;
  bool requiredGeoFencingForMarkIn;
  bool requiredSelfieForSurvey;
  bool requiredBulkAttendance;
  bool requiredEmailChange;
  bool requiredPhoneChange;
  bool requiredPasswordChange;
  bool requiresAllFillCampigned;
  bool requiredClientNameForSurvey;
  bool requiredMultiImageInCampaign;
  bool requiredFwpStore;
  bool requiredGstfromRetailer;
  bool requiredDoubleMarkIn;
  bool requiredMultiStore;
  bool requiredAddCampaignBeat;
  bool requiredAddMechanic;
  bool allowPrefilledQuestion;

  Configuration({
       required this.requiredAddMechanic,
     required this.requiredAddCampaignBeat,
       required this.requiredMultiStore,
       required this.requiredDoubleMarkIn,
      required this.requiredGstfromRetailer,
      required this.requiredFwpStore,
      required this.requiredStartDuty,
      required this.requiredSelfieForStartDuty,
      required this.requiredSelfieForMarkIn,
      required this.requiredGeoFencingForMarkIn,
      required this.requiredSelfieForSurvey,
      required this.requiredBulkAttendance,
      required this.requiredEmailChange,
      required this.requiredPhoneChange,
      required this.requiredPasswordChange,
      required this.requiresAllFillCampigned,
      required this.requiredMultiImageInCampaign,
      required this.requiredClientNameForSurvey,
      this.allowPrefilledQuestion = false});

  factory Configuration.fromJson(Map<String, dynamic> json) => Configuration(
    requiredAddMechanic: json["requiredAddMechanic"]?? false,
      requiredAddCampaignBeat:json["requiredAddCampaignBeat"]?? false,
      requiredMultiStore:json["requiredMultiStore"]??false,
      requiredDoubleMarkIn:json["requiredDoubleMarkIn"]??false,
      requiredGstfromRetailer: json['requiredGstfromRetailer']??false,
      requiredFwpStore:json['requiredFwpStore']??false,
      requiredMultiImageInCampaign: json['requiredMultiImageInCampaign']??false,
      requiredStartDuty: json["requiredStartDuty"] ?? false,
      requiresAllFillCampigned: json['requiresAllFillCampigned'] ?? false,
      requiredSelfieForStartDuty: json['requiredSelfieForStartDuty'] ?? true,
      requiredSelfieForMarkIn: json['requiredSelfieForMarkIn'] ?? true,
      requiredGeoFencingForMarkIn: json['requiredGeoFencingForMarkIn'] ?? true,
      requiredSelfieForSurvey: json["requiredSelfieForSurvey"] ?? true,
      requiredBulkAttendance: json['requiredBulkAttendance'] ?? true,
      requiredEmailChange: json['requiredEmailChange'] ?? true,
      requiredPhoneChange: json["requiredPhoneChange"] ?? true,
      requiredPasswordChange: json['requiredPasswordChange'] ?? true,
      requiredClientNameForSurvey: json['requiredClientNameForSurvey'] ?? true,
      allowPrefilledQuestion: json['allowPrefilledQuestion'] == true);

  Map<String, dynamic> toJson() => {
    "requiredAddMechanic":requiredAddMechanic,
        "requiredAddCampaignBeat":requiredAddCampaignBeat,
        "requiredMultiStore":requiredMultiStore,
        "requiredDoubleMarkIn":requiredDoubleMarkIn,
        "requiredGstfromRetailer":requiredGstfromRetailer,
        "requiredFwpStore":requiredFwpStore,
        "requiredMultiImageInCampaign": requiredMultiImageInCampaign,
        "requiresAllFillCampigned": requiresAllFillCampigned,
        "requiredStartDuty": requiredStartDuty,
        'requiredSelfieForStartDuty': requiredSelfieForStartDuty,
        'requiredSelfieForMarkIn': requiredSelfieForMarkIn,
        'requiredGeoFencingForMarkIn': requiredGeoFencingForMarkIn,
        'requiredSelfieForSurvey': requiredSelfieForSurvey,
        "requiredBulkAttendance": requiredBulkAttendance,
        "requiredPasswordChange": requiredPasswordChange,
        "requiredPhoneChange": requiredPhoneChange,
        "requiredEmailChange": requiredEmailChange,
        'requiredClientNameForSurvey': requiredClientNameForSurvey,
        'allowPrefilledQuestion': allowPrefilledQuestion,
      };
}
