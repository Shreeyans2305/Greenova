import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/hive_boxes.dart';
import '../../../data/models/purchase_record_model.dart';
import '../../theme/app_theme.dart';

class PurchaseHistoryScreen extends ConsumerStatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  ConsumerState<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends ConsumerState<PurchaseHistoryScreen> {
  List<PurchaseRecord> _purchases = [];
  String _selectedFilter = 'All';
  final _filters = ['All', 'Food & Beverages', 'Personal Care', 'Household',
      'Electronics', 'Clothing', 'General'];

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  void _loadPurchases() {
    final all = HiveBoxes.getAllPurchases();
    setState(() {
      _purchases = _selectedFilter == 'All'
          ? all
          : all.where((p) => p.category == _selectedFilter).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
        actions: [
          if (_purchases.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filters.length,
              itemBuilder: (ctx, i) {
                final selected = _filters[i] == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_filters[i]),
                    selected: selected,
                    onSelected: (_) {
                      _selectedFilter = _filters[i];
                      _loadPurchases();
                    },
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: _purchases.isEmpty
                ? Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 56,
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No purchases yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _purchases.length,
                    itemBuilder: (ctx, i) => _buildPurchaseItem(_purchases[i], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseItem(PurchaseRecord purchase, bool isDark) {
    final gradeColor = AppTheme.getGradeColor(purchase.sustainabilityGrade);
    final diff = DateTime.now().difference(purchase.purchaseDate);
    String dateText;
    if (diff.inDays == 0) dateText = 'Today';
    else if (diff.inDays == 1) dateText = 'Yesterday';
    else if (diff.inDays < 7) dateText = '${diff.inDays} days ago';
    else dateText = '${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}';

    return Dismissible(
      key: Key(purchase.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.scoreBad.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.scoreBad),
      ),
      onDismissed: (_) => _deletePurchase(purchase),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppTheme.cardDark : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(purchase.sustainabilityGrade, style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: gradeColor))),
          ),
          title: Text(purchase.productName, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
          subtitle: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.primarySlate : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(purchase.category, style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Text(dateText, style: TextStyle(fontSize: 12,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
          ]),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(purchase.carbonScore.toStringAsFixed(0), style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 18,
              color: AppTheme.getCarbonScoreColor(purchase.carbonScore))),
            Text('CO₂', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
          ]),
        ),
      ),
    );
  }

  void _deletePurchase(PurchaseRecord purchase) async {
    await HiveBoxes.deletePurchase(purchase.id);
    _loadPurchases();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase removed')),
      );
    }
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await HiveBoxes.clearAllPurchases();
              _loadPurchases();
            },
            child: const Text('Clear', style: TextStyle(color: AppTheme.scoreBad)),
          ),
        ],
      ),
    );
  }
}
