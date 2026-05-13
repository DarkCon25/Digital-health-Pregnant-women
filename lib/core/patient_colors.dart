import 'package:flutter/material.dart';

/// HerCare — Patient portal palette (soft pink, white, medical blue).
class PatientColors {
  PatientColors._();

  // Sidebar
  static const Color sidebarBg = Color(0xFFFDF2F8);
  static const Color sidebarBorder = Color(0xFFFBD0E8);
  static const Color sidebarText = Color(0xFF64748B);
  static const Color sidebarActive = Color(0xFFEC4899);
  static const Color sidebarActiveBg = Color(0xFFFCE7F3);

  // Page
  static const Color pageBg = Color(0xFFF9FAFB);
  static const Color topbarBg = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF3E8F5);

  // Primary — Soft Rose Pink
  static const Color primary = Color(0xFFEC4899);
  static const Color primaryLight = Color(0xFFFBCFE8);
  static const Color primaryDark = Color(0xFFDB2777);
  static const Color primaryTint = Color(0xFFFDF2F8);

  // Medical Blue
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFDBEAFE);
  static const Color blueDark = Color(0xFF1D4ED8);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color critical = Color(0xFFEF4444);
  static const Color criticalLight = Color(0xFFFEE2E2);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Emergency
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyRedLight = Color(0xFFFEE2E2);
  static const Color emergencyPulse = Color(0xFFFF6B6B);

  // Card accents (health metrics)
  static const Color heartRate = Color(0xFFEF4444);
  static const Color bloodPressure = Color(0xFF8B5CF6);
  static const Color bloodSugar = Color(0xFFF59E0B);
  static const Color temperature = Color(0xFF06B6D4);
  static const Color weight = Color(0xFF10B981);
  static const Color fetalHR = Color(0xFFEC4899);
}
