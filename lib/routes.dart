import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/assessment_module/assessment_repository.dart';
import 'package:i_densfa/module/beatplan_stores_module/beat_plan_model.dart';
import 'package:i_densfa/module/campaign_module/bloc/campaign_bloc.dart';
import 'package:i_densfa/module/campaign_module/view/campaign_questions_view.dart';
import 'package:i_densfa/module/checkin_module/check_in_view.dart';
import 'package:i_densfa/module/inventory_module/inventory_view.dart';
import 'package:i_densfa/module/leaves_module/leave_view.dart';
import 'package:i_densfa/module/login_module/login_view.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_view.dart';
import 'package:i_densfa/module/promoter_module/bloc/promoter_bloc.dart';
import 'package:i_densfa/module/promoter_module/promoter_view.dart';
import 'package:i_densfa/module/store_detail_module/storeDetal/store_detail_bloc.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_repositry.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_view.dart';
import 'package:i_densfa/utility/app_storage.dart';

import 'module/assessment_module/bloc/assessment_bloc.dart';
import 'module/assessment_module/views/assessment_list_view.dart';
import 'module/assessment_module/views/assessment_questions_view.dart';
import 'module/assessment_module/views/selected_assessment_view.dart';
import 'module/beatplan_stores_module/schedule_visit/bloc/schedule_visit_call_bloc.dart';
import 'module/beatplan_stores_module/schedule_visit/schedule_visit_view.dart';
import 'module/forgot_password_module/forgot_password_view.dart';
import 'module/promoter_module/promoter_repository.dart';
import 'module/reset_password_module/reset_password_view.dart';
import 'module/splash_module/splash_view.dart';
import 'module/tabber_module/tabber_view.dart';
import 'module/upload_selfie/bloc/upload_selfie_bloc.dart';
import 'module/upload_selfie/upload_selfie.dart';
import 'module/verification_module/verification_view.dart';

final router = GoRouter(
  initialLocation:
      AppStorage().isLoggedIn() ? AppPaths.tabbar : AppPaths.initial,
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
            create: (context) => ScheduleVisitCallBloc(),
            child: const ScheduleVisitView());
      },
    ),
    GoRoute(
      path: AppPaths.login,
      name: AppPaths.login,
      builder: (context, state) => LoginView(),
    ),
    GoRoute(
      path: AppPaths.forgotpass,
      name: AppPaths.forgotpass,
      builder: (context, state) => ForgotPasswordView(),
    ),
    GoRoute(
      path: "${AppPaths.passVerification}/:email/:msg",
      name: AppPaths.passVerification,
      builder: (context, state) => VerificationView(
        email: state.params['email'] ?? "",
        msg: state.params['msg'] ?? "",
      ),
    ),
    GoRoute(
      path: "${AppPaths.resetPass}/:email/:otp",
      name: AppPaths.resetPass,
      builder: (context, state) => ResetPasswordView(
        email: state.params['email'] ?? "",
        otp: state.params['otp'] ?? "",
      ),
    ),
    GoRoute(
      path: AppPaths.checkin,
      name: AppPaths.checkin,
      builder: (context, state) => const CheckInView(),
    ),
    GoRoute(
      path: AppPaths.activity,
      name: AppPaths.activity,
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
  ],
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text(state.fullpath ??
            state.error?.toString() ??
            state.name ??
            "unknown error"),
      ),
    );
  },
);

class AppPaths {
  static const initial = '/';
  static const tabbar = '/tabbar';
  static const store = '/store';
  static const assessment = '/assessment';
  static const assessmentList = '/assessmentlist';
  static const assessmentQuestion = '/assessmentQuestion';
  static const campaignQuestion = '/campaignQuestion';
  static const selfie = '/selfie';
  static const inventory = '/inventory';
  static const scheduleVisit = '/scheduleVisit';
  static const resetPass = '/resetpass';
  static const login = '/login';
  static const passVerification = '/passVerification';
  static const forgotpass = '/forgotpass';
  static const checkin = '/checkin';
  static const activity = '/activity';
  static const leave = '/leave';
  static const promoter = '/promoter';
}
