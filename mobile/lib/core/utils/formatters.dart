import 'package:intl/intl.dart';

/// Date formatting utilities
class DateUtils {
  DateUtils._();

  static final _dateFormat = DateFormat('MMM dd, yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');

  /// Format date as "Jan 01, 2024"
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format time as "14:30"
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format as "Jan 01, 2024 14:30"
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Get relative time string (e.g., "2 hours ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else {
      return '${(diff.inDays / 365).floor()}y ago';
    }
  }

  /// Get month and year string (e.g., "January 2024")
  static String getMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Number formatting utilities
class NumberUtils {
  NumberUtils._();

  /// Format number with K/M suffix
  static String formatCompact(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  /// Format as percentage
  static String formatPercentage(double value, {int decimals = 0}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format carbon score with unit
  static String formatCarbonScore(double score) {
    return '${score.toStringAsFixed(0)} CO₂e';
  }
}

/// String utilities
class StringUtils {
  StringUtils._();

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Convert to title case
  static String toTitleCase(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
}
