import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextStyle _getTextStyle(
    TextStyle Function({
      TextStyle? textStyle,
      Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
    })
    googleFont, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    if (const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false) ||
        !GoogleFonts.config.allowRuntimeFetching) {
      return TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      );
    }
    return googleFont(color: color, fontSize: fontSize, fontWeight: fontWeight);
  }

  // Theme colors
  static const Color background = Colors.transparent;
  static const Color cardBg = Color(0x0CFFFFFF);
  static const Color border = Color(0x1FFFFFFF);
  static const Color textPrimary = Color(0xF5FFFFFF);
  static const Color textSecondary = Color(0xADFFFFFF);
  static const Color primary = Color(0xFF00BCD4);
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF4285F4);

  // Status colors matching React project
  static const Map<String, Color> statusColors = {
    'new': Color(0xFF3B82F6),
    'assigned': Color(0xFF6366F1),
    'in_progress': Color(0xFFF59E0B),
    'testing': Color(0xFF9333EA),
    'resolved': Color(0xFF10B981),
    'closed': Color(0xFF6B7280),
  };

  static const Map<String, String> statusLabels = {
    'new': 'Nová',
    'assigned': 'Priradená',
    'in_progress': 'V riešení',
    'testing': 'Testovanie',
    'resolved': 'Vyriešená',
    'closed': 'Uzatvorená',
  };

  // Severity colors matching React project
  static const Map<String, Color> severityColors = {
    'critical': Color(0xFFEF4444),
    'high': Color(0xFFF97316),
    'medium': Color(0xFFEAB308),
    'low': Color(0xFF3B82F6),
  };

  static const Map<String, String> severityLabels = {
    'critical': 'Kritická',
    'high': 'Vysoká',
    'medium': 'Stredná',
    'low': 'Nízka',
  };

  // Glassmorphic Decoration — matching wallpaper style
  static BoxDecoration glassDecoration({
    double borderRadius = 12.0,
    Color bgColor = const Color(0x0DFFFFFF),
    Color borderColor = const Color(0x1FFFFFFF),
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.0),
    );
  }

  // Active / Selected Glassmorphic card
  static BoxDecoration activeGlassDecoration({double borderRadius = 12.0}) {
    return BoxDecoration(
      color: const Color(0x1AFFFFFF),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: const Color(0x33FFFFFF), width: 1.2),
    );
  }

  // Dark ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: success,
        surface: cardBg,
        error: error,
        onPrimary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: _getTextStyle(
          GoogleFonts.outfit,
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: _getTextStyle(
          GoogleFonts.outfit,
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: _getTextStyle(
          GoogleFonts.outfit,
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: _getTextStyle(
          GoogleFonts.inter,
          color: textPrimary,
          fontSize: 14,
        ),
        bodyMedium: _getTextStyle(
          GoogleFonts.inter,
          color: textSecondary,
          fontSize: 13,
        ),
        labelLarge: _getTextStyle(
          GoogleFonts.inter,
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: border,
      cardTheme: CardThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }

  // Light ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: success,
        surface: Color(0xFFFFFFFF),
        error: error,
        onPrimary: Colors.white,
        onSurface: Color(0xFF1F1F1F),
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: _getTextStyle(
          GoogleFonts.outfit,
          color: const Color(0xFF1F1F1F),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: _getTextStyle(
          GoogleFonts.outfit,
          color: const Color(0xFF1F1F1F),
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: _getTextStyle(
          GoogleFonts.outfit,
          color: const Color(0xFF1F1F1F),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: _getTextStyle(
          GoogleFonts.inter,
          color: const Color(0xFF1F1F1F),
          fontSize: 14,
        ),
        bodyMedium: _getTextStyle(
          GoogleFonts.inter,
          color: const Color(0xFF616161),
          fontSize: 13,
        ),
        labelLarge: _getTextStyle(
          GoogleFonts.inter,
          color: const Color(0xFF1F1F1F),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: const Color(0xFFE0E0E0),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF1F1F1F)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1F1F1F)),
      ),
    );
  }
}
