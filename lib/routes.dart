import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/change_email_phone_module/change_email_phone_view.dart';
import 'package:i_densfa/module/login_verify_module/pin_login_view.dart';
import 'package:i_densfa/module/splash_module/splash_view.dart';
import 'package:i_densfa/utility/app_storage.dart';

import 'module/assessment_module/assessment_repository.dart';
import 'module/beatplan_stores_module/beat_plan_model.dart';
import 'module/campaign_module/bloc/campaign_bloc.dart';
import 'module/campaign_module/view/campaign_questions_view.dart';
import 'module/campaign_module/view/campaign_view.dart';
import 'module/change_password_module/change_password_view.dart';
import 'module/checkin_module/check_in_view.dart';
import 'module/inventory_module/inventory_view.dart';
import 'module/leaves_module/leave_view.dart';
import 'module/login_module/login_view.dart';
import 'module/login_set_pin_module/pin_setup_view.dart';
import 'module/my_activity_module/my_activity_view.dart';
import 'module/policy_module/policy_view.dart';
import 'module/promoter_module/bloc/promoter_bloc.dart';
import 'module/promoter_module/promoter_view.dart';
import 'module/setting_module/profile_info_view.dart';
import 'module/setting_module/setting_view.dart';
import 'module/store_detail_module/store_detail_repositry.dart';
import 'module/store_detail_module/store_detail_view.dart';
import 'module/web_module/web_view.dart';
import 'module/aboutus_module/aboutus_view.dart';
import 'module/assessment_module/bloc/assessment_bloc.dart';
import 'module/assessment_module/views/assessment_list_view.dart';
import 'module/assessment_module/views/assessment_questions_view.dart';
import 'module/assessment_module/views/selected_assessment_view.dart';
import 'module/attendance_module/attendance_view.dart';
import 'module/beatplan_stores_module/schedule_visit/bloc/schedule_visit_call_bloc.dart';
import 'module/beatplan_stores_module/schedule_visit/schedule_visit_view.dart';
import 'module/forgot_password_module/forgot_password_view.dart';
import 'module/promoter_module/promoter_repository.dart';
import 'module/reset_password_module/reset_password_view.dart';
import 'module/store_detail_module/bloc/store_detail_bloc.dart';
import 'module/tabber_module/tabber_view.dart';
import 'module/upload_selfie/bloc/upload_selfie_bloc.dart';
import 'module/upload_selfie/upload_selfie.dart';
import 'module/verification_module/verification_view.dart';

final router = GoRouter(
  initialLocation: AppStorage().isLoggedIn() &&
          int.tryParse(AppStorage().userDetail?.pin ?? "-1")?.isNegative ==
              false
      ? AppPaths.pinLogin
      : AppPaths.initial,
  routes: <RouteBase>[
    GoRoute(
      path: AppPaths.initial,
      name: AppPaths.initial,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppPaths.tabbar,
      name: AppPaths.tabbar,
      builder: (context, state) => const TabberView(),
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
      path: AppPaths.assessmentQuestion,
      name: AppPaths.assessmentQuestion,
      builder: (context, state) => BlocProvider.value(
        value: state.extra as AssessmentBloc,
        child: const AssessmentQuestionsView(),
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
      path: AppPaths.assessmentList,
      name: AppPaths.assessmentList,
      builder: (context, state) => BlocProvider(
        create: (context) => AssessmentBloc(AssessmentRepository())
          ..add(GetUserAssessmentsEvent()),
        child: const AssessmentListView(),
      ),
    ),
    GoRoute(
      path: AppPaths.assessment,
      name: AppPaths.assessment,
      builder: (context, state) {
        return BlocProvider.value(
            value: state.extra as AssessmentBloc,
            child: const SelectedAssessmentView());
      },
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
      builder: (context, state) => LoginView(),
    ),
    GoRoute(
        path: AppPaths.pinLogin,
        name: AppPaths.pinLogin,
        builder: (context, state) => const PinLoginView()),
    GoRoute(
        path: AppPaths.pinset,
        name: AppPaths.pinset,
        builder: (context, state) => const PinSetupView()),
    GoRoute(
      path: AppPaths.forgotpass,
      name: AppPaths.forgotpass,
      builder: (context, state) => ForgotPasswordView(),
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
      builder: (context, state) => const CheckInView(),
    ),
    GoRoute(
      path: AppPaths.attendance,
      name: AppPaths.attendance,
      builder: (context, state) => const AttendanceView(),
    ),
    GoRoute(
      path: AppPaths.myActivity,
      name: AppPaths.myActivity,
      builder: (context, state) => const MyActivityView(),
    ),
    GoRoute(
      path: AppPaths.promoter,
      name: AppPaths.promoter,
      builder: (context, state) => BlocProvider(
        create: (context) =>
            PromoterBloc(PromoterRepository())..add(GetStoreDetailEvent()),
        child: const PromoterView(),
      ),
    ),
    GoRoute(
      path: AppPaths.leave,
      name: AppPaths.leave,
      builder: (context, state) => const LeaveView(),
    ),
    GoRoute(
      path: AppPaths.setting,
      name: AppPaths.setting,
      builder: (context, state) => const SettingView(),
    ),
    GoRoute(
      path: AppPaths.changePass,
      name: AppPaths.changePass,
      builder: (context, state) => ChangePasswordView(),
    ),
    GoRoute(
      path: "${AppPaths.appwebview}/:link",
      name: AppPaths.appwebview,
      builder: (context, state) => AppWebView(
        link: state.pathParameters['link'] ?? "",
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
  static const appwebview = '/appwebview';
  static const assessment = '/assessment';
  static const assessmentList = '/assessmentlist';
  static const assessmentQuestion = '/assessmentQuestion';
  static const attendance = '/attendance';
  static const campaignQuestion = '/campaignQuestion';
  static const changePass = '/changePass';
  static const checkin = '/checkin';
  static const forgotpass = '/forgotpass';
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
  static const tabbar = '/tabbar';
  static const pinLogin = '/pinlogin';
  static const pinset = '/pinset';
  static const changeEmailPhone = "/changeEmailPhone";
  static const profileInfo = "/profileInfo";
}
