import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  String _filterCategory = 'All';
  final _dateFormat = DateFormat('MMM dd, yyyy');

  final List<String> _categories = [
    'All',
    'Food & Beverages',
    'Personal Care',
    'Household',
    'Electronics',
    'Clothing',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  void _loadPurchases() {
    setState(() {
      _purchases = HiveBoxes.getAllPurchases();
    });
  }

  List<PurchaseRecord> get _filteredPurchases {
    if (_filterCategory == 'All') return _purchases;
    return _purchases.where((p) => p.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPurchaseDialog,
            tooltip: 'Add manual purchase',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Summary
          _buildStatsSummary(),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((category) {
                final isSelected = category == _filterCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _filterCategory = category);
                    },
                    selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryGreen,
                  ),
                );
              }).toList(),
            ),
          ),

          // Purchase List
          Expanded(
            child: _filteredPurchases.isEmpty
                ? _buildEmptyState()
                : _buildPurchaseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final totalItems = _purchases.length;
    double avgScore = 0;
    if (totalItems > 0) {
      avgScore = _purchases.map((p) => p.carbonScore).reduce((a, b) => a + b) / totalItems;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.primaryGreenLight.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.shopping_bag,
            value: totalItems.toString(),
            label: 'Total Items',
            color: AppTheme.primaryGreen,
          ),
          _StatItem(
            icon: Icons.eco,
            value: avgScore.toStringAsFixed(1),
            label: 'Avg. Score',
            color: AppTheme.getCarbonScoreColor(avgScore),
          ),
          _StatItem(
            icon: Icons.category,
            value: _purchases.map((p) => p.category).toSet().length.toString(),
            label: 'Categories',
            color: AppTheme.secondaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _filterCategory == 'All'
                ? 'No purchases recorded'
                : 'No purchases in $_filterCategory',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan products or add them manually',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPurchaseDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Purchase'),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseList() {
    // Group purchases by date
    final groupedPurchases = <String, List<PurchaseRecord>>{};
    for (final purchase in _filteredPurchases) {
      final dateKey = _dateFormat.format(purchase.purchaseDate);
      groupedPurchases.putIfAbsent(dateKey, () => []).add(purchase);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: groupedPurchases.length,
      itemBuilder: (context, index) {
        final dateKey = groupedPurchases.keys.elementAt(index);
        final purchases = groupedPurchases[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ...purchases.map((purchase) => _buildPurchaseCard(purchase)),
          ],
        );
      },
    );
  }

  Widget _buildPurchaseCard(PurchaseRecord purchase) {
    final gradeColor = AppTheme.getGradeColor(purchase.sustainabilityGrade);

    return Dismissible(
      key: Key(purchase.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(purchase),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                purchase.sustainabilityGrade,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: gradeColor,
                ),
              ),
            ),
          ),
          title: Text(
            purchase.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              Icon(Icons.category, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(purchase.category),
              if (purchase.brand != null) ...[
                const SizedBox(width: 8),
                Text(
                  '| ${purchase.brand}',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                purchase.carbonScore.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getCarbonScoreColor(purchase.carbonScore),
                ),
              ),
              Text(
                'CO2',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(PurchaseRecord purchase) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: Text('Remove "${purchase.productName}" from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await HiveBoxes.deletePurchase(purchase.id);
              _loadPurchases();
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAddPurchaseDialog() {
    final nameController = TextEditingController();
    final scoreController = TextEditingController(text: '50');
    String selectedCategory = 'General';
    String selectedGrade = 'C';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Purchase Manually'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'e.g., Organic Shampoo',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: scoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carbon Score (0-100)',
                    hintText: 'Lower is better',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .where((c) => c != 'All')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGrade,
                  decoration: const InputDecoration(labelText: 'Grade'),
                  items: ['A', 'B', 'C', 'D', 'F']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedGrade = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final score = double.tryParse(scoreController.text) ?? 50;

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a product name')),
                  );
                  return;
                }

                final purchase = PurchaseRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  productName: name,
                  carbonScore: score.clamp(0, 100),
                  sustainabilityGrade: selectedGrade,
                  category: selectedCategory,
                  purchaseDate: DateTime.now(),
                  addedAt: DateTime.now(),
                );

                await HiveBoxes.addPurchase(purchase);
                _loadPurchases();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
