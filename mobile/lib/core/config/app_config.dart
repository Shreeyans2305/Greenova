/// App-wide configuration constants
class AppConfig {
  AppConfig._();

  static const String appName = 'GreenNova';
  static const String appVersion = '1.0.0';

  /// Database configuration
  static const String purchaseHistoryBox = 'purchase_history';
  static const String sustainabilityReportsBox = 'sustainability_reports';
  static const String userProfileBox = 'user_profile';
  static const String searchHistoryBox = 'search_history';

  /// Carbon footprint thresholds
  static const double lowCarbonThreshold = 30.0;
  static const double mediumCarbonThreshold = 60.0;
  static const double highCarbonThreshold = 100.0;

  /// Achievement thresholds
  static const int firstScanAchievement = 1;
  static const int tenScansAchievement = 10;
  static const int fiftyScansAchievement = 50;
  static const int hundredScansAchievement = 100;
}
