import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_densfa/module/checkin_module/check_in_view.dart';
import 'package:i_densfa/module/inventory_module/inventory_view.dart';
import 'package:i_densfa/module/leaves_module/leave_view.dart';
import 'package:i_densfa/module/login_module/login_view.dart';
import 'package:i_densfa/module/my_activity_module/my_activity_view.dart';
import 'package:i_densfa/module/promoter_module/promoter_view.dart';
import 'package:i_densfa/module/store_detail_module/store_detail_view.dart';

import 'module/assessment_module/bloc/assessment_bloc.dart';
import 'module/assessment_module/views/assessment_list_view.dart';
import 'module/assessment_module/views/assessment_questions_view.dart';
import 'module/assessment_module/views/selected_assessment_view.dart';
import 'module/forgot_password_module/forgot_password_view.dart';
import 'module/reset_password_module/reset_password_view.dart';
import 'module/splash_module/splash_view.dart';
import 'module/store_list_module/bloc/schedule_visit_call_bloc.dart';
import 'module/store_list_module/schedule_visit_view.dart';
import 'module/tabber_module/tabber_view.dart';
import 'module/upload_selfie/bloc/upload_selfie_bloc.dart';
import 'module/upload_selfie/upload_selfie.dart';
import 'module/verification_module/verification_view.dart';

final router = GoRouter(
  initialLocation: AppPaths.initial,
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
      builder: (context, state) => const StoreDetailView(),
    ),
    GoRoute(
      path: AppPaths.assessmentQuestion,
      name: AppPaths.assessmentQuestion,
      builder: (context, state) => const AssessmentQuestionsView(),
    ),
    GoRoute(
      path: AppPaths.assessmentList,
      name: AppPaths.assessmentList,
      builder: (context, state) => BlocProvider(
        create: (context) => AssessmentBloc(),
        child: const AssessmentListView(),
      ),
    ),
    GoRoute(
      path: AppPaths.assessment,
      name: AppPaths.assessment,
      builder: (context, state) {
        return BlocProvider.value(
            value: context.read<AssessmentBloc>(),
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
      builder: (context, state) => const InventoryView(),
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
      path: AppPaths.resetPass,
      name: AppPaths.resetPass,
      builder: (context, state) => ResetPasswordView(),
    ),
    GoRoute(
      path: AppPaths.login,
      name: AppPaths.login,
      builder: (context, state) => LoginView(),
    ),
    GoRoute(
      path: AppPaths.passVerification,
      name: AppPaths.passVerification,
      builder: (context, state) => const VerificationView(),
    ),
    GoRoute(
      path: AppPaths.forgotpass,
      name: AppPaths.forgotpass,
      builder: (context, state) => ForgotPasswordView(),
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
      builder: (context, state) => const PromoterView(),
    ),
    GoRoute(
      path: AppPaths.leave,
      name: AppPaths.leave,
      builder: (context, state) => LeaveView(),
    ),
  ],
  errorBuilder: (context, state) {
    return Text(state.fullpath ??
        state.error?.toString() ??
        state.name ??
        "unknown error");
  },
);

class AppPaths {
  static const initial = '/';
  static const tabbar = '/tabbar';
  static const store = '/store';
  static const assessment = '/assessment';
  static const assessmentList = '/assessmentlist';
  static const assessmentQuestion = '/assessmentQuestion';
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
