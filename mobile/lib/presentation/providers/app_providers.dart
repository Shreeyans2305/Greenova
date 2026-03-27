import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/hive_boxes.dart';
import '../../data/models/purchase_record_model.dart';
import '../../data/models/user_profile_model.dart';

/// Provider for user profile
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(HiveBoxes.currentUser);

  void refresh() {
    state = HiveBoxes.currentUser;
  }

  Future<void> addPurchase(double carbonScore) async {
    final updated = state.addPurchase(carbonScore);
    await HiveBoxes.updateUser(updated);
    state = updated;
  }

  Future<void> incrementScans() async {
    final updated = state.incrementScans();
    await HiveBoxes.updateUser(updated);
    state = updated;
  }
}

/// Provider for purchase history
final purchaseHistoryProvider = StateNotifierProvider<PurchaseHistoryNotifier, List<PurchaseRecord>>((ref) {
  return PurchaseHistoryNotifier();
});

class PurchaseHistoryNotifier extends StateNotifier<List<PurchaseRecord>> {
  PurchaseHistoryNotifier() : super(HiveBoxes.getAllPurchases());

  void refresh() {
    state = HiveBoxes.getAllPurchases();
  }

  Future<void> addPurchase(PurchaseRecord purchase) async {
    await HiveBoxes.addPurchase(purchase);
    state = HiveBoxes.getAllPurchases();
  }

  Future<void> deletePurchase(String id) async {
    await HiveBoxes.deletePurchase(id);
    state = HiveBoxes.getAllPurchases();
  }
}

/// Provider for filtered purchases by category
final filteredPurchasesProvider = Provider.family<List<PurchaseRecord>, String>((ref, category) {
  final purchases = ref.watch(purchaseHistoryProvider);
  if (category == 'All') return purchases;
  return purchases.where((p) => p.category == category).toList();
});

/// Provider for carbon statistics
final carbonStatsProvider = Provider<CarbonStats>((ref) {
  final purchases = ref.watch(purchaseHistoryProvider);

  if (purchases.isEmpty) {
    return CarbonStats(
      totalCarbon: 0,
      averageScore: 0,
      purchaseCount: 0,
      categoryBreakdown: {},
    );
  }

  final totalCarbon = purchases.fold(0.0, (sum, p) => sum + p.carbonScore);
  final categoryBreakdown = <String, double>{};

  for (final purchase in purchases) {
    categoryBreakdown[purchase.category] =
        (categoryBreakdown[purchase.category] ?? 0) + purchase.carbonScore;
  }

  return CarbonStats(
    totalCarbon: totalCarbon,
    averageScore: totalCarbon / purchases.length,
    purchaseCount: purchases.length,
    categoryBreakdown: categoryBreakdown,
  );
});

class CarbonStats {
  final double totalCarbon;
  final double averageScore;
  final int purchaseCount;
  final Map<String, double> categoryBreakdown;

  CarbonStats({
    required this.totalCarbon,
    required this.averageScore,
    required this.purchaseCount,
    required this.categoryBreakdown,
  });

  String get footprintLevel {
    if (averageScore < 30) return 'Low';
    if (averageScore < 60) return 'Medium';
    return 'High';
  }
}
