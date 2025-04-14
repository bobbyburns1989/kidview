import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kidview/core/utils/logger.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  static late final Environment environment;
  static late final String apiBaseUrl;
  static late final bool analyticsEnabled;
  static late final SharedPreferences prefs;
  
  // App-specific configuration
  static late final int maxVideoDurationForYoungerKids; // in minutes
  static late final int pinLength;
  static late final Duration sessionTimeout;
  static late final bool isDemo;
  
  static Future<void> initialize() async {
    // For demo purposes
    isDemo = true;
    
    // Set environment based on build configuration (defaulting to dev for now)
    environment = Environment.dev;
    
    // Configure API URL based on environment
    switch (environment) {
      case Environment.dev:
        apiBaseUrl = 'https://dev-api.kidview.app/v1';
        analyticsEnabled = false;
        break;
      case Environment.staging:
        apiBaseUrl = 'https://staging-api.kidview.app/v1';
        analyticsEnabled = true;
        break;
      case Environment.prod:
        apiBaseUrl = 'https://api.kidview.app/v1';
        analyticsEnabled = true;
        break;
    }
    
    try {
      // Even in demo mode, try to initialize SharedPreferences
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // Handle any potential errors silently
      Logger.e('Failed to initialize SharedPreferences: $e');
    }
    
    // Set app-specific configurations
    maxVideoDurationForYoungerKids = 15; // 15 minutes
    pinLength = 4;
    sessionTimeout = const Duration(minutes: 30);
  }
  
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
}