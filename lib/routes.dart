import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/assessment_module/assessment/assessment_bloc.dart';
import 'package:i_densfa/module/assessment_module/assessment_view.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:i_densfa/module/assessment_module/view/assessment_question.dart';
import 'package:i_densfa/module/assessment_module/view/assessment_result_view.dart';
import 'package:i_densfa/module/assessment_module/view/level_view.dart';
import 'package:i_densfa/module/change_email_phone_module/change_email_phone_view.dart';
import 'package:i_densfa/module/create_store_module/bloc/create_store_bloc.dart';
import 'package:i_densfa/module/create_store_module/create_store_repository.dart';
import 'package:i_densfa/module/create_store_module/create_store_view.dart';
import 'package:i_densfa/module/issues_management_module/issues_detail_module/issues_detail_view.dart';
import 'package:i_densfa/module/issues_management_module/issues_list_module/issues_management_view.dart';
import 'package:i_densfa/module/login_verify_module/pin_login_view.dart';
import 'package:i_densfa/module/splash_module/splash_view.dart';
import 'package:i_densfa/module/survey_module/bloc/survey_bloc.dart';
import 'package:i_densfa/module/survey_module/view/survey_questions_view.dart';
import 'package:i_densfa/module/survey_module/view/survey_list_view.dart';
import 'package:i_densfa/module/team_module/views/teams_main_view.dart';
import 'package:i_densfa/module/ui/camera_preview.dart';
import 'package:i_densfa/module/web_module/web_view.dart';
import 'package:i_densfa/utility/app_storage.dart';
import 'package:i_densfa/utility/extensions.dart';

import 'module/campaign_module/bloc/campaign_bloc.dart';
import 'module/campaign_module/view/campaign_questions_view.dart';
import 'module/campaign_module/view/campaign_view.dart';
import 'module/change_password_module/change_password_view.dart';
import 'module/checkin_module/check_in_view.dart';
import 'module/help_module/help_view.dart';
import 'module/inventory_module/inventory_view.dart';
import 'module/leaves_module/leave_view.dart';
import 'module/login_module/login_view.dart';
import 'module/login_set_pin_module/pin_setup_view.dart';
import 'module/my_activity_module/my_activity_view.dart';
import 'module/my_schedule_module/beat_plan_model.dart';
import 'module/my_schedule_module/schedule_visit/bloc/schedule_visit_call_bloc.dart';
import 'module/my_schedule_module/schedule_visit/schedule_visit_view.dart';
import 'module/notification/notification_view.dart';
import 'module/promoter_module/bloc/promoter_bloc.dart';
import 'module/promoter_module/promoter_view.dart';
import 'module/setting_module/profile_info_view.dart';
import 'module/setting_module/setting_view.dart';
import 'module/store_detail_module/store_detail_repository.dart';
import 'module/store_detail_module/store_detail_view.dart';
import 'module/survey_module/view/survey_detail_view.dart';
import 'module/team_module/models/team_list_model.dart';
import 'module/team_module/views/team_profile_view.dart';
import 'module/aboutus_module/aboutus_view.dart';
import 'module/policy_module/policy_view.dart';
import 'module/attendance_module/attendance_view.dart';
import 'module/device_registration_module/device_registration_view.dart';
import 'module/forgot_password_module/forgot_password_view.dart';
import 'module/promoter_module/promoter_repository.dart';
import 'module/reset_password_module/reset_password_view.dart';
import 'module/store_detail_module/bloc/store_detail_bloc.dart';
import 'module/tabber_module/tabbar_view.dart';
import 'module/upload_selfie/bloc/upload_selfie_bloc.dart';
import 'module/upload_selfie/upload_selfie.dart';
import 'module/verification_module/verification_view.dart';

final router = GoRouter(
  initialLocation: AppStorage().isLoggedIn() &&
          int.tryParse(AppStorage().userDetail?.pin ?? "-1")?.isNegative ==
              false
      ? AppPaths.pinLogin
      : AppPaths.initial,
  observers: <NavigatorObserver>[
    SentryNavigatorObserver(),
  ],
  routes: <RouteBase>[
    GoRoute(
      path: AppPaths.initial,
      name: AppPaths.initial,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppPaths.tabbar,
      name: AppPaths.tabbar,
      builder: (context, state) => const AppTabbarView(),
    ),
    GoRoute(
      path: AppPaths.store,
      name: AppPaths.store,
      builder: (context, state) => BlocProvider(
        create: (context) => StoreDetailBloc(
            StoreDetailRepository(), state.extra as BeatPlanModel),
        child: const StoreDetailView(),
      ),
    ),
    GoRoute(
      path: AppPaths.createStore,
      name: AppPaths.createStore,
      builder: (context, state) => BlocProvider(
        create: (context) => CreateStoreBloc(CreateStoreRepository()),
        child: const CreateStoreView(),
      ),
    ),
    GoRoute(
      path: AppPaths.campaignQuestion,
      name: AppPaths.campaignQuestion,
      builder: (context, state) => BlocProvider.value(
        value: state.extra as CampaignBloc,
        child: const CampaignQuestionsView(),
      ),
    ),
    GoRoute(
      path: AppPaths.selectedCampaignView,
      name: AppPaths.selectedCampaignView,
      builder: (context, state) => BlocProvider.value(
        value: state.extra as CampaignBloc,
        child: const SelectedCampaignView(),
      ),
    ),
    GoRoute(
      path: "${AppPaths.assessmentList}/:name",
      name: AppPaths.assessmentList,
      builder: (context, state) => AssessmentView(
        name: state.pathParameters['name'] ?? "Assessment",
      ),
    ),
    GoRoute(
      path: AppPaths.assessmentlevel,
      name: AppPaths.assessmentlevel,
      builder: (context, state) => BlocProvider.value(
          value: state.extra as AssessmentBloc, child: const LevelView()),
    ),
    GoRoute(
      path: AppPaths.assessmentQuestion,
      name: AppPaths.assessmentQuestion,
      builder: (context, state) => BlocProvider.value(
        value: state.extra as AssessmentBloc,
        child: const AssessmentQuestionsView(),
      ),
    ),
    GoRoute(
      path: AppPaths.assessmentResult,
      name: AppPaths.assessmentResult,
      builder: (context, state) => BlocProvider.value(
        value: state.extra as AssessmentBloc,
        child: const AssessmentResult(),
      ),
    ),
    GoRoute(
      path: AppPaths.selfie,
      name: AppPaths.selfie,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => UploadSelfieBloc(),
          child: const UploadSelfieView(),
        );
      },
    ),
    GoRoute(
      path: AppPaths.inventory,
      name: AppPaths.inventory,
      builder: (context, state) => BlocProvider.value(
        value: (state.extra as PromoterBloc)..add(GetInventoryDetailEvent()),
        child: const InventoryView(),
      ),
    ),
    GoRoute(
      path: AppPaths.scheduleVisit,
      name: AppPaths.scheduleVisit,
      builder: (context, state) {
        return BlocProvider(
            create: (context) =>
                ScheduleVisitCallBloc(state.extra as List<BeatPlanModel>),
            child: const ScheduleVisitView());
      },
    ),
    GoRoute(
      path: AppPaths.login,
      name: AppPaths.login,
      builder: (context, state) => LoginView(key: state.pageKey),
    ),
    GoRoute(
        path: AppPaths.pinLogin,
        name: AppPaths.pinLogin,
        builder: (context, state) => const PinLoginView()),
    GoRoute(
        path: AppPaths.team,
        name: AppPaths.team,
        builder: (context, state) => const TeamMainView()),
    GoRoute(
        path: AppPaths.pinset,
        name: AppPaths.pinset,
        builder: (context, state) => const PinSetupView()),
    GoRoute(
      path: AppPaths.forgotpass,
      name: AppPaths.forgotpass,
      builder: (context, state) => const ForgotPasswordView(),
    ),
    GoRoute(
      path: AppPaths.deviceRegistration,
      name: AppPaths.deviceRegistration,
      builder: (context, state) {
        final extra = state.extra;
        final username = extra is Map
            ? (extra['username']?.toString() ?? '')
            : '';
        return DeviceRegistrationView(initialUsername: username);
      },
    ),
    GoRoute(
      path: "${AppPaths.passVerification}/:email/:msg",
      name: AppPaths.passVerification,
      builder: (context, state) => VerificationView(
        email: state.pathParameters['email'] ?? "",
        msg: state.pathParameters['msg'] ?? "",
      ),
    ),
    GoRoute(
      path: "${AppPaths.resetPass}/:email/:otp",
      name: AppPaths.resetPass,
      builder: (context, state) => ResetPasswordView(
        email: state.pathParameters['email'] ?? "",
        otp: state.pathParameters['otp'] ?? "",
      ),
    ),
    GoRoute(
      path: AppPaths.checkin,
      name: AppPaths.checkin,
      builder: (context, state) {
        context.hideKeyboard();
        return const CheckInView();
      },
    ),
    GoRoute(
      path: "${AppPaths.attendance}/:name",
      name: AppPaths.attendance,
      builder: (context, state) => AttendanceView(
          name: state.pathParameters['name'] ?? "Attendance",
          forUserId: state.extra as int?),
    ),
    GoRoute(
      path: "${AppPaths.myActivity}/:name",
      name: AppPaths.myActivity,
      builder: (context, state) => MyActivityView(
          name: state.pathParameters['name'] ?? "My Activity",
          forUserId: state.extra as int?),
    ),
    GoRoute(
      path: "${AppPaths.promoter}/:name",
      name: AppPaths.promoter,
      builder: (context, state) => BlocProvider(
        create: (context) =>
            PromoterBloc(PromoterRepository())..add(GetStoreDetailEvent()),
        child: PromoterView(
          name: state.pathParameters['name'] ?? "Promoter",
        ),
      ),
    ),
    GoRoute(
      path: "${AppPaths.leave}/:name",
      name: AppPaths.leave,
      builder: (context, state) => LeaveView(
        name: state.pathParameters['name'] ?? "Leave",
      ),
    ),
    GoRoute(
      path: "${AppPaths.setting}/:name",
      name: AppPaths.setting,
      builder: (context, state) => SettingView(
        name: state.pathParameters['name'] ?? "Settings",
      ),
    ),
    GoRoute(
      path: AppPaths.changePass,
      name: AppPaths.changePass,
      builder: (context, state) => const ChangePasswordView(),
    ),
    GoRoute(
      path: "${AppPaths.appwebview}/:link/:contentType",
      name: AppPaths.appwebview,
      builder: (context, state) => AppWebView(
        link: state.pathParameters['link'] ?? "",
         contentType: state.pathParameters['contentType'] ?? "pdf",
      ),
    ),
    GoRoute(
      path: AppPaths.policy,
      name: AppPaths.policy,
      builder: (context, state) => const PolicyView(),
    ),
    GoRoute(
      path: AppPaths.aboutUs,
      name: AppPaths.aboutUs,
      builder: (context, state) => const AboutUsView(),
    ),
    GoRoute(
        path: AppPaths.issuesDetail,
        name: AppPaths.issuesDetail,
        builder: (context, state) =>
            IssuesDetailView(id: state.extra as String)),
    GoRoute(
      path: "${AppPaths.changeEmailPhone}/:changeEmail",
      name: AppPaths.changeEmailPhone,
      builder: (context, state) => ChangeEmailPhoneView(
          changeEmail:
              (state.pathParameters['changeEmail'] ?? "true") == "true"),
    ),
    GoRoute(
      path: AppPaths.profileInfo,
      name: AppPaths.profileInfo,
      builder: (context, state) => const ProfileInfoview(),
    ),
    GoRoute(
      path: AppPaths.notification,
      name: AppPaths.notification,
      builder: (context, state) => const NotificationsView(),
    ),
    GoRoute(
      path: AppPaths.teamProfile,
      name: AppPaths.teamProfile,
      builder: (context, state) =>
          TeamProfileView(memberDetail: state.extra as TeamMemberModel),
    ),
    GoRoute(
      path: "${AppPaths.appcamera}/:from",
      name: AppPaths.appcamera,
      builder: (context, state) => AppCameraPreview(
          from: state.pathParameters['from'] ?? "",
      ),
    ),
    GoRoute(
      path: AppPaths.help,
      name: AppPaths.help,
      builder: (context, state) => const HelpView(),
    ),
    GoRoute(
      path: "${AppPaths.surveyList}/:name",
      name: AppPaths.surveyList,
      builder: (context, state) => SurveyListView(
        name: state.pathParameters['name'] ?? "Survey",
      ),
    ),
    GoRoute(
      path: "${AppPaths.issuesManagement}/:name",
      name: AppPaths.issuesManagement,
      builder: (context, state) => IssuesManagementView(
        name: state.pathParameters['name'] ?? "Issues Management",
      ),
    ),
    GoRoute(
      path: AppPaths.surveyForm,
      name: AppPaths.surveyForm,
      builder: (context, state) => BlocProvider.value(
        value: state.extra as SurveyBloc,
        child: const SurveyQuestionsView(),
      ),
    ),
    GoRoute(
      path: AppPaths.selectedSurveyDetail,
      name: AppPaths.selectedSurveyDetail,
      builder: (context, state) => BlocProvider.value(
        value: state.extra as SurveyBloc,
        child: const SelectedSurveyView(),
      ),
    ),
  ],
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text(state.fullPath ??
            state.error?.toString() ??
            state.name ??
            "unknown error"),
      ),
    );
  },
);

class AppPaths {
  static const aboutUs = "/aboutus";
  static const help = "/help";
  static const appwebview = '/appwebview';
  static const assessmentlevel = '/assessmentlevel';
  static const assessmentList = '/assessmentlist';
  static const assessmentQuestion = '/assessmentQuestion';
  static const assessmentResult = "/assessmentResult";
  static const attendance = '/attendance';
  static const campaignQuestion = '/campaignQuestion';
  static const changePass = '/changePass';
  static const checkin = '/checkin';
  static const forgotpass = '/forgotpass';
  static const deviceRegistration = '/device-registration';
  static const initial = '/';
  static const inventory = '/inventory';
  static const leave = '/leave';
  static const login = '/login';
  static const myActivity = "/myActivity";
  static const passVerification = '/passVerification';
  static const policy = "/policy";
  static const promoter = '/promoter';
  static const resetPass = '/resetpass';
  static const scheduleVisit = '/scheduleVisit';
  static const selectedCampaignView = '/selectedCampaignView';
  static const selfie = '/selfie';
  static const setting = '/setting';
  static const store = '/store';
  static const createStore = '/createStore';
  static const tabbar = '/tabbar';
  static const pinLogin = '/pinlogin';
  static const pinset = '/pinset';
  static const changeEmailPhone = "/changeEmailPhone";
  static const profileInfo = "/profileInfo";
  static const notification = '/notification';
  static const team = '/team';
  static const teamProfile = '/teamProfile';
  static const surveyList = '/surveyList';
  static const issuesManagement = '/issuesManagement';
  static const issuesDetail = '/issuesDetail';
  static const selectedSurveyDetail = '/selectedSurveyDetail';
  static const surveyForm = '/surveyForm';
  static const appcamera = "/appcamera";
}
