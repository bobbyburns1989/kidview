import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/data/services/analytics_service.dart';
import 'package:kidview/features/authentication/screens/splash_screen.dart';
import 'package:kidview/features/authentication/screens/onboarding_screen.dart';
import 'package:kidview/features/authentication/screens/login_screen.dart';
import 'package:kidview/features/authentication/screens/register_screen.dart';
import 'package:kidview/features/authentication/screens/email_verification_screen.dart';
import 'package:kidview/features/parent_dashboard/screens/parent_home_screen.dart';
import 'package:kidview/features/parent_dashboard/screens/parental_controls_screen.dart';
import 'package:kidview/features/parent_dashboard/screens/viewing_history_screen.dart';
import 'package:kidview/features/parent_dashboard/screens/content_filter_screen.dart';
import 'package:kidview/features/parent_dashboard/screens/analytics_dashboard_screen.dart';
import 'package:kidview/features/child_interface/screens/child_home_screen.dart';
import 'package:kidview/features/child_interface/screens/child_library_screen.dart';
import 'package:kidview/features/child_interface/screens/video_player_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // Analytics instance for route tracking
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _analyticsObserver = 
      FirebaseAnalyticsObserver(analytics: _analytics);

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    observers: [_analyticsObserver],
    onException: (_, GoRouterState state, GoRouter router) {
      // Log routing errors to analytics
      _analytics.logEvent(
        name: 'routing_error',
        parameters: {
          'location': state.uri.toString(),
          'name': state.name ?? 'unknown',
        },
      );
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.emailVerification,
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      
      // Parent routes
      GoRoute(
        path: Routes.parentHome,
        builder: (context, state) => const ParentHomeScreen(),
      ),
      GoRoute(
        path: Routes.parentControls,
        builder: (context, state) => const ParentalControlsScreen(),
      ),
      GoRoute(
        path: Routes.parentHistory,
        builder: (context, state) => const ViewingHistoryScreen(),
      ),
      GoRoute(
        path: Routes.parentContentFilters,
        builder: (context, state) => const ContentFilterScreen(),
      ),
      GoRoute(
        path: Routes.parentAnalytics,
        builder: (context, state) => const AnalyticsDashboardScreen(),
        // Log analytics page view (additional tracking)
        onExit: (context) {
          AnalyticsService().logFeatureUse(
            featureName: 'analytics_dashboard',
            userId: Provider.of<AuthProvider>(context, listen: false).userId ?? 'unknown',
            isParent: true,
          );
          return true;
        },
      ),
      
      // Child routes
      GoRoute(
        path: Routes.childHome,
        builder: (context, state) {
          final ageGroup = state.uri.queryParameters['ageGroup'] ?? 'younger';
          return ChildHomeScreen(ageGroup: ageGroup);
        },
      ),
      GoRoute(
        path: Routes.childLibrary,
        builder: (context, state) {
          final ageGroup = state.uri.queryParameters['ageGroup'] ?? 'younger';
          return ChildLibraryScreen(ageGroup: ageGroup);
        },
      ),
      
      // Video player route
      GoRoute(
        path: '${Routes.videoPlayer}/:id',
        builder: (context, state) {
          final videoId = state.pathParameters['id'] ?? '1';
          final ageGroup = state.uri.queryParameters['ageGroup'] ?? 'younger';
          return VideoPlayerScreen(videoId: videoId, ageGroup: ageGroup);
        },
      ),
    ],
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isEmailVerified = authProvider.isEmailVerified;
      final isLoading = authProvider.isLoading;
      
      // Auth status check
      final isAuthRoute = [
        Routes.splash, 
        Routes.onboarding, 
        Routes.login, 
        Routes.register,
        Routes.emailVerification,
      ].contains(state.matchedLocation);
      
      // Don't redirect while loading auth status
      if (isLoading) return null;
      
      // Handle splash screen (entry point)
      if (state.matchedLocation == Routes.splash) {
        if (isAuthenticated) {
          if (!isEmailVerified) {
            return Routes.emailVerification;
          }
          return Routes.parentHome;
        }
        return Routes.onboarding;
      }
      
      // If not authenticated, redirect to login unless already on an auth route
      if (!isAuthenticated && !isAuthRoute) {
        return Routes.login;
      }
      
      // If authenticated but email not verified, redirect to verification screen
      // unless already on verification screen
      if (isAuthenticated && !isEmailVerified && 
          state.matchedLocation != Routes.emailVerification) {
        return Routes.emailVerification;
      }
      
      // If authenticated and verified, redirect away from auth routes
      if (isAuthenticated && isEmailVerified && isAuthRoute) {
        return Routes.parentHome;
      }
      
      // Allow all other routes
      return null;
    },
  );
}