import 'package:flutter/foundation.dart';

/// A simple logger utility to replace print statements in production code
class Logger {
  /// Private constructor to prevent instantiation
  Logger._();
  
  /// Log levels
  static const int _DEBUG = 0;
  static const int _INFO = 1;
  static const int _WARNING = 2;
  static const int _ERROR = 3;
  
  /// Whether to show debug logs
  static bool showDebugLogs = kDebugMode;
  
  /// Log a debug message
  static void d(String message) {
    if (showDebugLogs) {
      _log(_DEBUG, message);
    }
  }
  
  /// Log an info message
  static void i(String message) {
    _log(_INFO, message);
  }
  
  /// Log a warning message
  static void w(String message) {
    _log(_WARNING, message);
  }
  
  /// Log an error message
  static void e(String message) {
    _log(_ERROR, message);
  }
  
  /// Internal logging function
  static void _log(int level, String message) {
    if (kDebugMode) {
      final prefix = _getLevelPrefix(level);
      debugPrint('$prefix $message');
    }
  }
  
  /// Get prefix for log level
  static String _getLevelPrefix(int level) {
    switch (level) {
      case _DEBUG:
        return '🔍 DEBUG:';
      case _INFO:
        return '📘 INFO:';
      case _WARNING:
        return '⚠️ WARNING:';
      case _ERROR:
        return '❌ ERROR:';
      default:
        return 'LOG:';
    }
  }
}