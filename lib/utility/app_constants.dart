import 'package:flutter/material.dart';

class ImageConstants {
  static const logo = "assets/images/logo.png";
  static const denSfa = "assets/images/denSFA.png";
  static const poweredBy = "assets/images/poweredBy.png";
  static const videoPlayer = "assets/images/videoPlayer.png";
  static const pdf = "assets/images/pdf.png";
  static const triangle = "assets/images/triangle.svg";
  static const leavemask = "assets/images/leavemask.svg";
  static const inventoryMask = "assets/images/inventoryMask.svg";
  static const product = "assets/images/product.svg";
  static const pinBack = "assets/images/pinback.jpeg";

  static const filter = "assets/icons/filter.svg";
  static const doorOut = "assets/icons/doorOut.svg";
  static const sick = "assets/icons/sick.svg";
  static const walkman = "assets/icons/walkman.svg";
  static const sunumbrella = "assets/icons/sunumbrella.svg";
  static const line = "assets/icons/line.svg";
  static const navigator = "assets/icons/navigator.svg";
  static const box = "assets/icons/box.svg";
  static const campaign = "assets/icons/campaign.svg";
  static const feedback = "assets/icons/feedback.svg";
  static const scan = "assets/icons/scan.svg";

  static const miniCalendar = "assets/icons/store/calendar-mini.svg";
  static const creditCard = "assets/icons/store/credit-card.svg";
  static const credits = "assets/icons/store/credits.svg";
  static const notesT = "assets/icons/store/notes-t.svg";
  static const paperPen = "assets/icons/store/paper-pen.svg";
  static const stars = "assets/icons/store/stars.svg";
  static const statistic = "assets/icons/store/statistic.svg";
  static const telephone = "assets/icons/store/telephone.svg";
  static const visitsCalls = "assets/icons/store/visits-calls.svg";
  static const fileView = "assets/images/file_view.svg";
}

class AppConstant {
  static const storeRange = 250;
}

class URLConstants {
  URLConstants._();
  static const baseURLStart = String.fromEnvironment('BASE_URL');
  static const isfaBaseURL = '$baseURLStart/iSFA';
  static const apiBaseUrl = "$isfaBaseURL/api";
  static const loginAuth = "$apiBaseUrl/auth";
  static const sidemenuDetails = '$apiBaseUrl/user/home';
  static const version = "v1";

  static const updatefcmtoken = "$loginAuth/updatefcmtoken";
  static const login = "$loginAuth/login";
  static const setpin = "$loginAuth/set-pin";
  static const loginwithpin = "$loginAuth/loginwithpin";
  static const forgotPassword = "$loginAuth/$version/forgot-password";
  static const verifyotp = "$loginAuth/$version/verify-otp";
  static const resetPassword = "$loginAuth/$version/reset-password";
  static const updatePassword = "$loginAuth/$version/update-password";
  static const updateProfilePic = "$loginAuth/upload-profile-pic";
  static const updateProfile = "$loginAuth/update";

  static const leaveDetails = "$apiBaseUrl/getEmpLeaveDetails";
  static const leaves = '$apiBaseUrl/leave';
  static const applyLeave = '$leaves/addLeaveRequest';
  static const leaveRequest = '$leaves/updateLeaveRequest';

  static const getCategoryList = '$apiBaseUrl/getCategoryList';
  static const addInventory = '$apiBaseUrl/addInventory';
  static const saleProduct = '$apiBaseUrl/saleProduct';

  static const promoterStoreDetail = '$apiBaseUrl/getPromoterDetail';
  static const getInventory = '$apiBaseUrl/getInventory';
  static const getCompaingns = '$apiBaseUrl/getCampaignListByStoreId';

  static const getFeedbackPurposes = '$apiBaseUrl/getFeedbackPurposes';
  static const createFeedback = '$apiBaseUrl/createFeedback';
  static const markin = '$apiBaseUrl/MarkIn';
  static const markOut = '$apiBaseUrl/MarkOut';
  static const startDuty = '$apiBaseUrl/StartDuty';
  static const endDuty = '$apiBaseUrl/EndDuty';

  static const beatPlans = '$apiBaseUrl/V2/beatPlan';
  static const getStores = '$apiBaseUrl/getStoreList';
  static const beatPlanUpload = '$apiBaseUrl/beatPlanUpload';
  static const attendence = '$apiBaseUrl/attendance';
  static const activities = '$isfaBaseURL/activities';

  static const getAssessmentListByUserId =
      '$apiBaseUrl/getAssessmentListByUserId';
  static const getAssessmentQuestions = '$apiBaseUrl/getAssessmentDetails';
  static const saveAssessmentAnswers = '$apiBaseUrl/saveAssessmentAnswers';

  static const getAllCampaigns =
      '$baseURLStart/campaign-service/iSFA/api/v1/campaign';
  static const getCampaignQuestions =
      '$baseURLStart/campaign-service/iSFA/api/v1/campaign';
  static const saveCampaignAnswers = '$apiBaseUrl/saveCampaignAnswers';
  static const getStoreDetail = '$apiBaseUrl/getStoreDetail';
  static const addNote = '$apiBaseUrl/addNote';
  static const deleteNote = '$apiBaseUrl/deleteNote';
  static const savedCampaignResponse = '$apiBaseUrl/savedCampaignResponse';
  static const sheduleVisit = '$apiBaseUrl/beatPlanUpload';
  static const learnerContent = '$isfaBaseURL/server/learner-content';
  static const getFeedbackByUserIdAndStore =
      "$isfaBaseURL/api/getFeedbackByUserIdAndStore";
  static const getNotifications =
      "$apiBaseUrl/notification/userspecificnotifications";
  static const getTeamMembers = "$apiBaseUrl/teams/list-view";
  static const getTeamData = "$apiBaseUrl/teams/kpi";
}

class ColorConstants {
  static const amber = Color(0xffffbe00);
  static const amberFade = Color(0xffffda6a);
  static const grey = Color(0xff363636);
  static const greyFade = Color(0xff5b5b5b);
}
