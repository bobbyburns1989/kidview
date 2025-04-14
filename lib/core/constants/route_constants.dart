class Routes {
  // Authentication
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String emailVerification = '/email-verification';
  
  // Parent routes
  static const String parentHome = '/parent/home';
  static const String parentLibrary = '/parent/library';
  static const String parentSettings = '/parent/settings';
  static const String parentControls = '/parent/controls';
  static const String parentHistory = '/parent/history';
  static const String parentContentFilters = '/parent/content-filters';
  static const String parentAnalytics = '/parent/analytics';
  
  // Child routes
  static const String childHome = '/child/home';
  static const String childLibrary = '/child/library';
  static const String videoPlayer = '/video';
}