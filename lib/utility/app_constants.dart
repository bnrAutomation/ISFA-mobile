import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageConstants {
  static const String gradien = "assets/anim/gradien.json";
  static const String graph = "assets/anim/graph.json";
  static const String logo = "assets/images/logo.png";
  static const String denSfa = "assets/images/denSFA.png";
  static const String poweredBy = "assets/images/poweredBy.png";
  static const String videoPlayer = "assets/images/videoPlayer.png";
  static const String pdf = "assets/images/pdf.png";
  static const String triangle = "assets/images/triangle.svg";
  static const String leavemask = "assets/images/leavemask.svg";
  static const String inventoryMask = "assets/images/inventoryMask.svg";
  static const String product = "assets/images/product.svg";
  static const String pinBack = "assets/images/pinback.jpeg";

  static const String filter = "assets/icons/filter.svg";
  static const String doorOut = "assets/icons/doorOut.svg";
  static const String sick = "assets/icons/sick.svg";
  static const String walkman = "assets/icons/walkman.svg";
  static const String sunumbrella = "assets/icons/sunumbrella.svg";
  static const String line = "assets/icons/line.svg";
  static const String navigator = "assets/icons/navigator.svg";
  static const String box = "assets/icons/box.svg";
  static const String campaign = "assets/icons/campaign.svg";
  static const String feedback = "assets/icons/feedback.svg";
  static const String feedbackWhite = "assets/icons/feedbackWhite.svg";
  static const String scan = "assets/icons/scan.svg";

  static const String miniCalendar = "assets/icons/store/calendar-mini.svg";
  static const String creditCard = "assets/icons/store/credit-card.svg";
  static const String credits = "assets/icons/store/credits.svg";
  static const String notesT = "assets/icons/store/notes-t.svg";
  static const String paperPen = "assets/icons/store/paper-pen.svg";
  static const String stars = "assets/icons/store/stars.svg";
  static const String statistic = "assets/icons/store/statistic.svg";
  static const String telephone = "assets/icons/store/telephone.svg";
  static const String visitsCalls = "assets/icons/store/visits-calls.svg";
  static const String fileView = "assets/images/file_view.svg";
  static const String placeholderUserUrl =
      'https://tastevibe.web.app/assets/images/placeholder-user.png';
}

class AppConstant {
  static const int storeRange = 250;
  static const bool geoFencingEnable = false;
  static int notificationCount = 0;
  static String sectionExpire = "sectionExpire";
   static String updateAnylitec = "updateAnylitec";
  static String tokenupdate = "tokenupdate";

  static final ThemeData darkTheme = ThemeData.light().copyWith(
      //  scaffoldBackgroundColor: Colors.grey.shade100,
      colorScheme: ThemeData.light().colorScheme.copyWith(
          onSurface: Colors.black,
          primary: Colors.amber,
          onPrimary: Colors.black),
      textTheme: buildTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
          backgroundColor: ColorConstants.amber,
          centerTitle: true,
          elevation: 2,
          //foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black)),
      primaryColor: Colors.amber,
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.amber,
        disabledColor: Colors.grey,
      ));

  static final ThemeData lightTheme = ThemeData.light().copyWith(
      //scaffoldBackgroundColor: Colors.grey.shade100,
      colorScheme: ThemeData.light().colorScheme.copyWith(
          onSurface: Colors.black,
          primary: Colors.amber,
          onPrimary: Colors.black,
          secondary: Colors.black),
      primaryColor: Colors.amber,
      textTheme: buildTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
          backgroundColor: ColorConstants.amber,
          centerTitle: true,
          elevation: 2,
          //foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black)),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.amber,
        disabledColor: Colors.grey,
      ));
  static TextTheme buildTextTheme(TextTheme base) {
    TextTheme newBase = GoogleFonts.metrophobicTextTheme(base);
    return newBase
        .copyWith(
          displaySmall: newBase.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Display',
          ),
          headlineMedium: newBase.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Display',
          ),
          headlineSmall: newBase.headlineSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          titleLarge: newBase.titleLarge?.copyWith(fontSize: 18.0),
          bodySmall: newBase.bodySmall?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          bodyMedium: newBase.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          bodyLarge: newBase.bodyLarge?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          titleMedium: newBase.titleMedium?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
          labelLarge: newBase.labelLarge?.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
        )
        .apply(
          displayColor: Colors.grey.shade900,
          bodyColor: Colors.grey.shade900,
        )
        .copyWith(
          displayLarge: GoogleFonts.metrophobicTextTheme(newBase)
              .displayLarge
              ?.copyWith(),
          displayMedium: GoogleFonts.metrophobicTextTheme(newBase)
              .displayMedium
              ?.copyWith(),
          headlineSmall: GoogleFonts.metrophobicTextTheme(newBase)
              .headlineSmall
              ?.copyWith(),
          titleLarge:
              GoogleFonts.metrophobicTextTheme(newBase).titleLarge?.copyWith(),
        );
  }
}

class URLConstants {
  URLConstants._();

  //base Url----------------------------------------------------------------------

  static const String baseURLStart = String.fromEnvironment('BASE_URL');
  static const String isfaBaseURL = '$baseURLStart/iSFA';
  static const String apiBaseUrl = "$isfaBaseURL/api";
  static const String loginAuth = "$apiBaseUrl/auth";
  static const String sidemenuDetails = "$baseURLStart/iSFA/client/modules";
  static const String version = "v1";

 // Auth end point---------------------------------------------------------------------

  static const String userDetails ="$baseURLStart/authentication-service/iam/api/v1/user/detail";
  static const String updatefcmtoken = "$loginAuth/updatefcmtoken";
  static const String login ="$baseURLStart/authentication-service/iam/api/v1/authenticate";
  static const String logout ="$baseURLStart/authentication-service/iam/api/v1/logout-user";
  /// Submit request to register a new device (admin approval flow).
  static const String deviceRegistrationRequest =
      "$baseURLStart/authentication-service/iam/api/v1/device-registration/request";
  /// Check status of a pending device registration request.
  static const String deviceRegistrationStatus =
      "$baseURLStart/authentication-service/iam/api/v1/device-registration/status";
  // static const String userDetails = "$apiBaseUrl/user/detail";
  static const String setpin = "$loginAuth/set-pin";
  static const String loginwithpin = "$loginAuth/loginwithpin";
  static const String forgotPassword = "$loginAuth/$version/forgot-password";
  static const String verifyotp = "$loginAuth/$version/verify-otp";
  static const String resetPassword = "$loginAuth/$version/reset-password";
  static const String updatePassword = "$loginAuth/$version/update-password";
  static const String updateProfilePic = "$loginAuth/upload-profile-pic";
  static const String updateProfile = "$loginAuth/update";


// Leave Module------------------------------------------------------------------------


  static const String leaveDetails = "$apiBaseUrl/getEmpLeaveDetails";
  static const String getEmpLeaveBalanceDetails="$apiBaseUrl/getEmpLeaveBalanceDetails";
  static const String leaves = '$apiBaseUrl/leave';
  static const String applyLeave = '$leaves/addLeaveRequest';
  static const String leaveRequest = '$leaves/updateLeaveRequest';
  static const String upcommingLeave = '$isfaBaseURL/clientleaves/holiday';
  //'$isfaBaseURL/clientleaves/compulsatoryleaves';
  static const String optionalleaves ='$isfaBaseURL/clientleaves/optionalleaves';
  static const String weekoffleaves = '$isfaBaseURL/clientleaves/weekOff';
  static const String saveoptionalleaves = '$isfaBaseURL/clientleaves/saveoptionalleaves';


//Inventory Module-------------------------------------------------------------------------


  static const String getCategoryList = '$apiBaseUrl/getCategoryList';
  static const String category = '$apiBaseUrl/category';
  static const String subcategories = '$apiBaseUrl/subcategories/byCategory';
  static const String productNames = '$apiBaseUrl/productNames';

  static const String addInventory = '$apiBaseUrl/addInventory';
  static const String saleProduct = '$apiBaseUrl/saleProduct';

  static const String promoterStoreDetail = '$apiBaseUrl/getPromoterDetail';
  static const String getInventory = '$apiBaseUrl/getInventory';
  static const String getCompaingns = '$apiBaseUrl/getCampaignListByStoreId';

  static const String getFeedbackPurposes = '$apiBaseUrl/getFeedbackPurposes';
  static const String createFeedback = '$apiBaseUrl/createFeedback';
  static const String helpSupport = '$apiBaseUrl/help-support';
  static const String markin = '$apiBaseUrl/MarkIn';
  static const String markOut = '$apiBaseUrl/MarkOut';
  static const String startDuty = '$apiBaseUrl/StartDuty';
  static const String endDuty = '$apiBaseUrl/EndDuty';


  static const String getAllStores = '$apiBaseUrl/getAllStores';
  static const String searchStore = '$apiBaseUrl/searchStores';
  static const String createStore = '$apiBaseUrl/saveStore';
 static const String checkActivity = '$apiBaseUrl/check';

  static const String beatPlans = '$apiBaseUrl/V2/beatPlan';
  static const String beatPlansSuper = '$apiBaseUrl/V2/beatPlan/supervisor';
  
  static const String getStores = '$apiBaseUrl/getStoreList';
  static const String beatPlanUpload = '$apiBaseUrl/beatPlanUpload';

  static const String mechanicVisits = '$isfaBaseURL/mechanic/visits';
  static const String mechanicAll = '$isfaBaseURL/mechanic/all';

  static const String attendence = '$apiBaseUrl/attendance';
  static const String bulkattendance = '$apiBaseUrl/bulkInsert';
    //bulkattendance';
  static const String attendenceRequest = '$apiBaseUrl/all';
  static const String attendanceApprove = "$apiBaseUrl/bulkApprove";
  
 // '$apiBaseUrl/approvebymanager';
  static const String attandanceLeave = '$apiBaseUrl/leave/user';

  static const String activities = '$isfaBaseURL/activities';

  static const String getAssessmentListByUserId =
      '$apiBaseUrl/getAssessmentListByUserId';
  static const String getAssessmentQuestions =
      '$apiBaseUrl/getAssessmentDetails';
  static const String saveAssessmentAnswers =
      '$apiBaseUrl/saveAssessmentAnswers';

  static const String getAllClientCampaigns =
      '$baseURLStart/campaign-service/iSFA/api/v1/client/campaign/campaign-response';

  static const String getAllCampaigns =
      '$baseURLStart/campaign-service/iSFA/api/v1/campaign/client';
  static const String getAllCampaignsList =
      '$baseURLStart/campaign-service/iSFA/api/v1/campaign';
  static const String saveCampaignImage =
      '$baseURLStart/campaign-service/iSFA/api/v1/campaign/image';
  static const String storeBeatPlan =
      '$baseURLStart/campaign-service/iSFA/api/v1/storeBeatPlan';

  static const String saveCampaignAnswers = '$apiBaseUrl/saveCampaignAnswers';
  static const String getStoreDetail = '$apiBaseUrl/getStoreDetail';
  static const String addNote = '$apiBaseUrl/addNote';
  static const String deleteNote = '$apiBaseUrl/deleteNote';
  static const String savedCampaignResponse =
      '$apiBaseUrl/savedCampaignResponse';
  static const String sheduleVisit = '$apiBaseUrl/beatPlanUpload';
  static const String updateBeatPlan = '$apiBaseUrl/updateBeatPlan';

  static const String learnerContent = '$isfaBaseURL/server/learner-content';
  static const String getFeedbackByUserIdAndStore =
      "$isfaBaseURL/api/getFeedbackByUserIdAndStore";
  static const String getNotifications =
      "$apiBaseUrl/notification/userspecificnotifications";
  static const String getTeamMembers = "$apiBaseUrl/teams/list-view";
  static const String getTeamData = "$apiBaseUrl/teams/kpi";
  static const String teamNotification = "$apiBaseUrl/teams/notification";
  static const String surveyServiceBaseUrl =
      "$baseURLStart/survey-service/iSFA/api/v1";
  static const String getAllSurveysList = '$surveyServiceBaseUrl/survey';
  static const String getSurveyBeatPlans = '$surveyServiceBaseUrl/getBeatPlan';
  static const String createSurveyNotes = '$surveyServiceBaseUrl/notes/survey';

  static const String assessmentServiceBaseUrl =
      "$baseURLStart/assessment-service/iSFA/api/v1";
  static const String getAllAssessmentList =
      '$assessmentServiceBaseUrl/assessments';
  static const String getAllAssessmentLevel =
      '$assessmentServiceBaseUrl/client/assessment';

  static const String getTicket = "$baseURLStart/issue/client/campaign/tickets";
  static const String allTickets =
      "$baseURLStart/issue/client/campaign/allTickets";
  static const String filterTickets =
      "$baseURLStart/issue/client/campaign/filterTickets";
  static const String campaignExists = '$isfaBaseURL/api/campaign/exists';
  
  static String get placeApiUrl => "$apiBaseUrl/places/search";
}

class ColorConstants {
  static const Color amber = Color(0xffffbe00);
  static const Color amberFade = Color(0xffffda6a);
  static const Color grey = Color(0xff363636);
  static const Color greyFade = Color(0xff5b5b5b);
}
