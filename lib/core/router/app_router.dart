import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/features/onboarding/presentation/pages/splash_page.dart';
import 'package:ableone_app/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:ableone_app/features/authentication/presentation/pages/login_page.dart';
import 'package:ableone_app/features/authentication/presentation/pages/signup_page.dart';
import 'package:ableone_app/features/authentication/presentation/pages/role_selection_page.dart';
import 'package:ableone_app/features/dashboard/presentation/pages/student_dashboard_page.dart';
import 'package:ableone_app/features/dashboard/presentation/pages/parent_dashboard_page.dart';
import 'package:ableone_app/features/dashboard/presentation/pages/counselor_dashboard_page.dart';
import 'package:ableone_app/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:ableone_app/features/learning/presentation/pages/course_list_page.dart';
import 'package:ableone_app/features/learning/presentation/pages/course_details_page.dart';
import 'package:ableone_app/features/learning/presentation/pages/module_list_page.dart';
import 'package:ableone_app/features/learning/presentation/pages/lesson_viewer_page.dart';
import 'package:ableone_app/features/learning/presentation/pages/progress_page.dart';
import 'package:ableone_app/features/ai/presentation/pages/ai_home_page.dart';
import 'package:ableone_app/features/ai/presentation/pages/ai_chat_page.dart';
import 'package:ableone_app/features/ai/presentation/pages/ai_chat_history_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: RouteNames.splash,
        path: RouteNames.splashPath,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        name: RouteNames.welcome,
        path: RouteNames.welcomePath,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        name: RouteNames.login,
        path: RouteNames.loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: RouteNames.signup,
        path: RouteNames.signupPath,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        name: RouteNames.roleSelection,
        path: RouteNames.roleSelectionPath,
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        name: RouteNames.studentDashboard,
        path: RouteNames.studentDashboardPath,
        builder: (context, state) => const StudentDashboardPage(),
      ),
      GoRoute(
        name: RouteNames.parentDashboard,
        path: RouteNames.parentDashboardPath,
        builder: (context, state) => const ParentDashboardPage(),
      ),
      GoRoute(
        name: RouteNames.counselorDashboard,
        path: RouteNames.counselorDashboardPath,
        builder: (context, state) => const CounselorDashboardPage(),
      ),
      GoRoute(
        name: RouteNames.adminDashboard,
        path: RouteNames.adminDashboardPath,
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        name: RouteNames.courseList,
        path: RouteNames.courseListPath,
        builder: (context, state) => const CourseListPage(),
      ),
      GoRoute(
        name: RouteNames.courseDetails,
        path: RouteNames.courseDetailsPath,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return CourseDetailsPage(courseId: courseId);
        },
      ),
      GoRoute(
        name: RouteNames.moduleList,
        path: RouteNames.moduleListPath,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return ModuleListPage(courseId: courseId);
        },
      ),
      GoRoute(
        name: RouteNames.lessonViewer,
        path: RouteNames.lessonViewerPath,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final moduleId = state.pathParameters['moduleId'] ?? '';
          final lessonId = state.pathParameters['lessonId'] ?? '';
          return LessonViewerPage(
            courseId: courseId,
            moduleId: moduleId,
            lessonId: lessonId,
          );
        },
      ),
      GoRoute(
        name: RouteNames.progressScreen,
        path: RouteNames.progressScreenPath,
        builder: (context, state) => const ProgressPage(),
      ),
      GoRoute(
        name: RouteNames.aiHome,
        path: RouteNames.aiHomePath,
        builder: (context, state) => const AIHomePage(),
      ),
      GoRoute(
        name: RouteNames.aiChat,
        path: RouteNames.aiChatPath,
        builder: (context, state) {
          final initialPrompt = state.extra as String? ?? '';
          return AIChatPage(initialPrompt: initialPrompt);
        },
      ),
      GoRoute(
        name: RouteNames.aiHistory,
        path: RouteNames.aiHistoryPath,
        builder: (context, state) => const AIChatHistoryPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('No route defined for ${state.uri}'),
      ),
    ),
  );
});
