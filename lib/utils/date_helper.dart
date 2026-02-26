import 'package:intl/intl.dart';

/// Utility functions for date formatting and calculations.
class DateHelper {
  DateHelper._();

  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _shortFormat = DateFormat('dd MMM');
  static final DateFormat _fullFormat = DateFormat('EEEE, MMMM dd, yyyy');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  /// Format: "Jan 01, 2024"
  static String formatDisplay(DateTime date) => _displayFormat.format(date);

  /// Format: "01 Jan"
  static String formatShort(DateTime date) => _shortFormat.format(date);

  /// Format: "Monday, January 01, 2024"
  static String formatFull(DateTime date) => _fullFormat.format(date);

  /// Format: "2024-01-01"
  static String formatIso(DateTime date) => _isoFormat.format(date);

  /// Format a date range: "Jan 01 - Jan 05, 2024"
  static String formatRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${_shortFormat.format(start)} - ${_displayFormat.format(end)}';
    }
    return '${_displayFormat.format(start)} - ${_displayFormat.format(end)}';
  }

  /// Calculate the number of working days between two dates (Mon–Fri).
  static int workingDaysBetween(DateTime start, DateTime end) {
    int count = 0;
    DateTime current = start;
    while (!current.isAfter(end)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  /// Calculate calendar days between two dates (inclusive).
  static int calendarDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  /// Returns a human-readable "time ago" string.
  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDisplay(dateTime);
  }

  /// Returns true if the date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns the start of the current month.
  static DateTime startOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  /// Returns the end of the current month.
  static DateTime endOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 0, 23, 59, 59);
  }
}
