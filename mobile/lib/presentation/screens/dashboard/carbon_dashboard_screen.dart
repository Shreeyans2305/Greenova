import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/hive_boxes.dart';
import '../../../data/models/purchase_record_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../theme/app_theme.dart';

class CarbonDashboardScreen extends ConsumerStatefulWidget {
  const CarbonDashboardScreen({super.key});

  @override
  ConsumerState<CarbonDashboardScreen> createState() => _CarbonDashboardScreenState();
}

class _CarbonDashboardScreenState extends ConsumerState<CarbonDashboardScreen> {
  late UserProfile _user;
  late List<PurchaseRecord> _purchases;
  Map<String, double> _categoryBreakdown = {};
  List<Map<String, dynamic>> _monthlyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _user = HiveBoxes.currentUser;
    _purchases = HiveBoxes.getAllPurchases();
    _calculateCategoryBreakdown();
    _calculateMonthlyData();
    setState(() {});
  }

  void _calculateCategoryBreakdown() {
    _categoryBreakdown = {};
    for (final purchase in _purchases) {
      _categoryBreakdown[purchase.category] =
          (_categoryBreakdown[purchase.category] ?? 0) + purchase.carbonScore;
    }
  }

  void _calculateMonthlyData() {
    final monthlyMap = <String, Map<String, dynamic>>{};

    for (final purchase in _purchases) {
      final key = '${purchase.purchaseDate.month}/${purchase.purchaseDate.year}';
      if (!monthlyMap.containsKey(key)) {
        monthlyMap[key] = {
          'month': key,
          'totalCarbon': 0.0,
          'itemCount': 0,
        };
      }
      monthlyMap[key]!['totalCarbon'] += purchase.carbonScore;
      monthlyMap[key]!['itemCount'] += 1;
    }

    _monthlyData = monthlyMap.values.toList();
    _monthlyData.sort((a, b) {
      final aDate = a['month'].toString().split('/');
      final bDate = b['month'].toString().split('/');
      final aYear = int.parse(aDate[1]);
      final bYear = int.parse(bDate[1]);
      if (aYear != bYear) return aYear.compareTo(bYear);
      return int.parse(aDate[0]).compareTo(int.parse(bDate[0]));
    });

    // Keep last 6 months
    if (_monthlyData.length > 6) {
      _monthlyData = _monthlyData.sublist(_monthlyData.length - 6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgScore = _purchases.isNotEmpty
        ? _user.totalCarbonFootprint / _purchases.length
        : 0.0;
    final levelColor = _getLevelColor(_user.footprintLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Dashboard'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _purchases.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Score Card
                  _buildOverallScoreCard(avgScore, levelColor),
                  const SizedBox(height: 24),

                  // Gamification Section
                  _buildGamificationSection(),
                  const SizedBox(height: 24),

                  // Monthly Trend Chart
                  if (_monthlyData.isNotEmpty) ...[
                    const Text(
                      'Monthly Trend',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMonthlyChart(),
                    const SizedBox(height: 24),
                  ],

                  // Category Breakdown
                  if (_categoryBreakdown.isNotEmpty) ...[
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryBreakdown(),
                    const SizedBox(height: 24),
                  ],

                  // Achievements
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAchievements(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No data yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning products to see your carbon footprint',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(double avgScore, Color levelColor) {
    final isWarning = _user.footprintLevel == 'High';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              levelColor.withOpacity(0.1),
              levelColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // Warning/Reward Banner
            if (isWarning)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your carbon footprint is high. Consider more sustainable choices!',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            else if (_user.footprintLevel == 'Low')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.scoreExcellent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.scoreExcellent.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.eco, color: AppTheme.scoreExcellent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Great job! Your sustainable choices are making a difference!',
                        style: TextStyle(color: AppTheme.scoreExcellent),
                      ),
                    ),
                  ],
                ),
              ),

            // Score Display
            Row(
              children: [
                // Circular Score
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: (avgScore / 100).clamp(0, 1),
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(levelColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            avgScore.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: levelColor,
                            ),
                          ),
                          const Text(
                            'AVG',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_user.footprintLevel} Impact',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: levelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _StatRow(
                        icon: Icons.shopping_bag,
                        label: 'Products tracked',
                        value: _user.totalPurchases.toString(),
                      ),
                      const SizedBox(height: 4),
                      _StatRow(
                        icon: Icons.cloud,
                        label: 'Total CO2e',
                        value: _user.totalCarbonFootprint.toStringAsFixed(0),
                      ),
                      const SizedBox(height: 4),
                      _StatRow(
                        icon: Icons.qr_code_scanner,
                        label: 'Total scans',
                        value: _user.totalScans.toString(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationSection() {
    final progress = (_user.totalPurchases / 100).clamp(0.0, 1.0);
    final nextMilestone = _getNextMilestone(_user.totalPurchases);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_user.totalPurchases} / $nextMilestone',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _user.totalPurchases / nextMilestone,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${nextMilestone - _user.totalPurchases} more products to next achievement!',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  int _getNextMilestone(int current) {
    if (current < 10) return 10;
    if (current < 50) return 50;
    if (current < 100) return 100;
    return ((current ~/ 100) + 1) * 100;
  }

  Widget _buildMonthlyChart() {
    if (_monthlyData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _monthlyData
                      .map((d) => (d['totalCarbon'] as double))
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              barGroups: _monthlyData.asMap().entries.map((entry) {
                final value = entry.value['totalCarbon'] as double;
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: AppTheme.getCarbonScoreColor(
                        value / (entry.value['itemCount'] as int),
                      ),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= _monthlyData.length) {
                        return const SizedBox.shrink();
                      }
                      final month = _monthlyData[value.toInt()]['month']
                          .toString()
                          .split('/')[0];
                      return Text(
                        month,
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final total = _categoryBreakdown.values.fold(0.0, (a, b) => a + b);
    final sortedEntries = _categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppTheme.primaryGreen,
      AppTheme.secondaryTeal,
      AppTheme.accentYellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedEntries.asMap().entries.map((entry) {
            final category = entry.value.key;
            final value = entry.value.value;
            final percentage = (value / total * 100);
            final color = colors[entry.key % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                      Text(
                        '${value.toStringAsFixed(0)} CO2 (${percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final allAchievements = [
      {'name': 'First Scan!', 'icon': Icons.celebration, 'desc': 'Scan your first product'},
      {'name': 'Eco Explorer', 'icon': Icons.explore, 'desc': 'Track 10 products'},
      {'name': 'Sustainability Champion', 'icon': Icons.workspace_premium, 'desc': 'Track 50 products'},
      {'name': 'Green Guardian', 'icon': Icons.shield, 'desc': 'Track 100 products'},
      {'name': 'Low Impact Hero', 'icon': Icons.eco, 'desc': 'Maintain low carbon footprint'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: allAchievements.map((achievement) {
        final earned = _user.achievements.contains(achievement['name']);

        return Container(
          width: MediaQuery.of(context).size.width / 2 - 24,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: earned
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: earned
                  ? AppTheme.primaryGreen.withOpacity(0.3)
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                achievement['icon'] as IconData,
                size: 32,
                color: earned ? AppTheme.primaryGreen : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                achievement['name'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: earned ? AppTheme.primaryGreen : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                achievement['desc'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Low':
        return AppTheme.scoreExcellent;
      case 'Medium':
        return AppTheme.scoreFair;
      case 'High':
        return AppTheme.scorePoor;
      default:
        return Colors.grey;
    }
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
