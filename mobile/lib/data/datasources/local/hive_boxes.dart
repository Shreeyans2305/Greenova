import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../models/purchase_record_model.dart';
import '../../models/search_history_model.dart';
import '../../models/sustainability_report_model.dart';
import '../../models/user_profile_model.dart';

/// Manages Hive database boxes
class HiveBoxes {
  HiveBoxes._();

  static late Box<PurchaseRecord> purchaseHistoryBox;
  static late Box<SustainabilityReport> sustainabilityReportsBox;
  static late Box<UserProfile> userProfileBox;
  static late Box<SearchHistoryItem> searchHistoryBox;

  /// Initialize all Hive boxes and register adapters
  static Future<void> init() async {
    // Register type adapters
    Hive.registerAdapter(SustainabilityReportAdapter());
    Hive.registerAdapter(PurchaseRecordAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(SearchHistoryItemAdapter());

    // Open boxes
    purchaseHistoryBox = await Hive.openBox<PurchaseRecord>(
      AppConfig.purchaseHistoryBox,
    );
    sustainabilityReportsBox = await Hive.openBox<SustainabilityReport>(
      AppConfig.sustainabilityReportsBox,
    );
    userProfileBox = await Hive.openBox<UserProfile>(
      AppConfig.userProfileBox,
    );
    searchHistoryBox = await Hive.openBox<SearchHistoryItem>(
      AppConfig.searchHistoryBox,
    );

    // Initialize user profile if not exists
    if (userProfileBox.isEmpty) {
      await userProfileBox.put('current', UserProfile.initial());
    }
  }

  /// Get current user profile
  static UserProfile get currentUser {
    return userProfileBox.get('current') ?? UserProfile.initial();
  }

  /// Update user profile
  static Future<void> updateUser(UserProfile profile) async {
    await userProfileBox.put('current', profile);
  }

  /// Add a purchase record
  static Future<void> addPurchase(PurchaseRecord record) async {
    await purchaseHistoryBox.put(record.id, record);

    // Update user profile
    final user = currentUser.addPurchase(record.carbonScore);
    await updateUser(user);
  }

  /// Get all purchases sorted by date (newest first)
  static List<PurchaseRecord> getAllPurchases() {
    final purchases = purchaseHistoryBox.values.toList();
    purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    return purchases;
  }

  /// Delete a purchase
  static Future<void> deletePurchase(String id) async {
    await purchaseHistoryBox.delete(id);
  }

  /// Cache a sustainability report
  static Future<void> cacheReport(SustainabilityReport report) async {
    await sustainabilityReportsBox.put(report.id, report);
  }

  /// Get cached report by ID
  static SustainabilityReport? getCachedReport(String id) {
    return sustainabilityReportsBox.get(id);
  }

  /// Add search history item
  static Future<void> addSearchHistory(SearchHistoryItem item) async {
    await searchHistoryBox.put(item.id, item);
  }

  /// Get recent searches (limit to 10)
  static List<SearchHistoryItem> getRecentSearches() {
    final searches = searchHistoryBox.values.toList();
    searches.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return searches.take(10).toList();
  }

  /// Clear all search history
  static Future<void> clearSearchHistory() async {
    await searchHistoryBox.clear();
  }

  /// Close all boxes
  static Future<void> close() async {
    await purchaseHistoryBox.close();
    await sustainabilityReportsBox.close();
    await userProfileBox.close();
    await searchHistoryBox.close();
  }
}
