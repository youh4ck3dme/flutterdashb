import 'package:flutter/material.dart';

/// Provider for managing theme mode (light/dark/system)
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Set the theme mode and notify listeners
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // If system, check system brightness and toggle to opposite
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      setThemeMode(brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light);
    }
  }

  /// Check if currently in light mode (requires BuildContext for system mode)
  bool isLightMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return Theme.of(context).brightness == Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }

  /// Check if currently in dark mode (requires BuildContext for system mode)
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return Theme.of(context).brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}
