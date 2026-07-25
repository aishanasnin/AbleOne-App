class RouteNames {
  static const String splash = 'splash';
  static const String splashPath = '/';

  static const String welcome = 'welcome';
  static const String welcomePath = '/welcome';

  static const String login = 'login';
  static const String loginPath = '/login';

  static const String signup = 'signup';
  static const String signupPath = '/signup';

  static const String roleSelection = 'roleSelection';
  static const String roleSelectionPath = '/role-selection';

  static const String studentDashboard = 'studentDashboard';
  static const String studentDashboardPath = '/dashboard/student';

  static const String parentDashboard = 'parentDashboard';
  static const String parentDashboardPath = '/dashboard/parent';

  static const String counselorDashboard = 'counselorDashboard';
  static const String counselorDashboardPath = '/dashboard/counselor';

  static const String adminDashboard = 'adminDashboard';
  static const String adminDashboardPath = '/dashboard/admin';

  static const String courseList = 'courseList';
  static const String courseListPath = '/courses';

  static const String courseDetails = 'courseDetails';
  static const String courseDetailsPath = '/courses/:courseId';

  static const String moduleList = 'moduleList';
  static const String moduleListPath = '/courses/:courseId/modules';

  static const String lessonViewer = 'lessonViewer';
  static const String lessonViewerPath = '/courses/:courseId/modules/:moduleId/lessons/:lessonId';

  static const String progressScreen = 'progressScreen';
  static const String progressScreenPath = '/progress';

  static const String aiHome = 'aiHome';
  static const String aiHomePath = '/ai';

  static const String aiChat = 'aiChat';
  static const String aiChatPath = '/ai/chat';

  static const String aiHistory = 'aiHistory';
  static const String aiHistoryPath = '/ai/history';

  static const String profilePage = 'profilePage';
  static const String profilePagePath = '/profile';

  static const String accessibilitySetup = 'accessibilitySetup';
  static const String accessibilitySetupPath = '/profile/accessibility-setup';

  static const String learningPreference = 'learningPreference';
  static const String learningPreferencePath = '/profile/learning-preference';
}
