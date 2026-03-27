/// Product categories used across the app
class ProductCategories {
  ProductCategories._();

  static const List<String> all = [
    'Food & Beverages',
    'Personal Care',
    'Household',
    'Electronics',
    'Clothing',
    'General',
  ];

  static const List<String> withAll = [
    'All',
    ...all,
  ];

  /// Get icon for category
  static String getIcon(String category) {
    switch (category) {
      case 'Food & Beverages':
        return '🍎';
      case 'Personal Care':
        return '🧴';
      case 'Household':
        return '🏠';
      case 'Electronics':
        return '📱';
      case 'Clothing':
        return '👕';
      default:
        return '📦';
    }
  }
}

/// Sustainability grade helper
class GradeHelper {
  GradeHelper._();

  static const List<String> grades = ['A', 'B', 'C', 'D', 'F'];

  static String getGradeFromScore(double score) {
    if (score < 20) return 'A';
    if (score < 40) return 'B';
    if (score < 60) return 'C';
    if (score < 80) return 'D';
    return 'F';
  }

  static String getGradeDescription(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return 'Excellent - Highly sustainable choice';
      case 'B':
        return 'Good - Above average sustainability';
      case 'C':
        return 'Average - Moderate environmental impact';
      case 'D':
        return 'Below Average - Consider alternatives';
      case 'F':
        return 'Poor - High environmental impact';
      default:
        return 'Unknown';
    }
  }
}

/// Carbon footprint level helper
class FootprintHelper {
  FootprintHelper._();

  static String getLevel(double averageScore) {
    if (averageScore < 30) return 'Low';
    if (averageScore < 60) return 'Medium';
    return 'High';
  }

  static String getLevelDescription(String level) {
    switch (level) {
      case 'Low':
        return 'Great job! Your choices are making a real difference for the environment.';
      case 'Medium':
        return 'You\'re on the right track. Consider more sustainable alternatives when possible.';
      case 'High':
        return 'Your carbon footprint is above average. Look for eco-friendly alternatives.';
      default:
        return 'Start tracking products to see your impact.';
    }
  }

  static String getLevelEmoji(String level) {
    switch (level) {
      case 'Low':
        return '🌱';
      case 'Medium':
        return '🌿';
      case 'High':
        return '⚠️';
      default:
        return '❓';
    }
  }
}
