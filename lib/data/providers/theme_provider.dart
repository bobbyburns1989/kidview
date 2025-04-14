import 'package:flutter/material.dart';
import 'package:kidview/config/themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isYoungerChildView = false;
  bool _isOlderChildView = false;

  ThemeMode get themeMode => _themeMode;
  bool get isYoungerChildView => _isYoungerChildView;
  bool get isOlderChildView => _isOlderChildView;
  
  // Returns the appropriate theme based on current settings
  ThemeData getTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isYoungerChildView) {
      return _getYoungerChildTheme(isDark);
    } else if (_isOlderChildView) {
      return _getOlderChildTheme(isDark);
    } else {
      return isDark ? AppThemes.darkTheme : AppThemes.lightTheme;
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void setYoungerChildView(bool value) {
    _isYoungerChildView = value;
    if (value) _isOlderChildView = false;
    notifyListeners();
  }
  
  void setOlderChildView(bool value) {
    _isOlderChildView = value;
    if (value) _isYoungerChildView = false;
    notifyListeners();
  }
  
  void setParentView() {
    _isYoungerChildView = false;
    _isOlderChildView = false;
    notifyListeners();
  }
  
  // Younger children theme variant
  ThemeData _getYoungerChildTheme(bool isDark) {
    final baseTheme = isDark ? AppThemes.darkTheme : AppThemes.lightTheme;
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppThemes.primaryYounger,
        secondary: AppThemes.secondaryYounger,
        surface: isDark ? const Color(0xFF2D2D2D) : AppThemes.backgroundYounger,
      ),
      textTheme: baseTheme.textTheme.copyWith(
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
          fontSize: 22,
        ),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          fontSize: 20,
        ),
      ),
      iconTheme: baseTheme.iconTheme.copyWith(
        size: 32,
      ),
    );
  }
  
  // Older children theme variant
  ThemeData _getOlderChildTheme(bool isDark) {
    final baseTheme = isDark ? AppThemes.darkTheme : AppThemes.lightTheme;
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppThemes.primaryOlder,
        secondary: AppThemes.secondaryOlder,
        surface: isDark ? const Color(0xFF202020) : AppThemes.backgroundOlder,
      ),
      textTheme: baseTheme.textTheme.copyWith(
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
          fontSize: 20,
        ),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          fontSize: 16,
        ),
      ),
      iconTheme: baseTheme.iconTheme.copyWith(
        size: 28,
      ),
    );
  }
}