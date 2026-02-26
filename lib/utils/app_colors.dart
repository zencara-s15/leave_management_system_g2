import 'package:flutter/material.dart';

/// Central color palette for the app.
/// TODO: Customize these colors to match your desired theme.
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF1565C0);       // Deep Blue
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);

  // Accent
  static const Color accent = Color(0xFF00ACC1);

  // Role-specific colors
  static const Color employeeColor = Color(0xFF1565C0);
  static const Color managerColor = Color(0xFF2E7D32);
  static const Color adminColor = Color(0xFF6A1B9A);

  // Status colors
  static const Color pending = Color(0xFFF57C00);
  static const Color approved = Color(0xFF2E7D32);
  static const Color rejected = Color(0xFFC62828);

  // Leave type colors
  static const Color sickLeave = Color(0xFFE53935);
  static const Color casualLeave = Color(0xFF1E88E5);
  static const Color vacationLeave = Color(0xFF43A047);
  static const Color maternityLeave = Color(0xFF8E24AA);
  static const Color paternityLeave = Color(0xFF00897B);
  static const Color otherLeave = Color(0xFF6D4C41);

  // UI surface colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;

  // Notification badge
  static const Color notificationBadge = Color(0xFFE53935);

  /// Returns the color for a given leave status string.
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return approved;
      case 'rejected':
        return rejected;
      case 'pending':
      default:
        return pending;
    }
  }

  /// Returns the color for a given leave type code.
  static Color leaveTypeColor(String code) {
    switch (code.toLowerCase()) {
      case 'sick':
        return sickLeave;
      case 'casual':
        return casualLeave;
      case 'vacation':
        return vacationLeave;
      case 'maternity':
        return maternityLeave;
      case 'paternity':
        return paternityLeave;
      default:
        return otherLeave;
    }
  }
}
