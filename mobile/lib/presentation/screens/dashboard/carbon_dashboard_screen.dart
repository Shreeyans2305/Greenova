import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../../data/models/purchase_record_model.dart';
import '../../../data/models/user_profile_model.dart';
import '../../providers/theme_provider.dart';
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
        monthlyMap[key] = {'month': key, 'totalCarbon': 0.0, 'itemCount': 0};
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
    if (_monthlyData.length > 6) {
      _monthlyData = _monthlyData.sublist(_monthlyData.length - 6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgScore = _purchases.isNotEmpty
        ? _user.totalCarbonFootprint / _purchases.length : 0.0;
    final levelColor = _getLevelColor(_user.footprintLevel);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Dashboard'),
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Purchase History',
            onPressed: () => context.push(AppRoutes.history),
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
        ],
      ),
      body: _purchases.isEmpty
          ? _buildEmptyState(isDark)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverallScoreCard(avgScore, levelColor, isDark),
                  const SizedBox(height: 24),
                  _buildImpactEquivalents(isDark),
                  const SizedBox(height: 28),
                  _buildGamificationSection(isDark),
                  const SizedBox(height: 28),
                  if (_monthlyData.isNotEmpty) ...[
                    _sectionTitle('Monthly Trend', isDark),
                    const SizedBox(height: 16),
                    _buildMonthlyChart(isDark),
                    const SizedBox(height: 28),
                  ],
                  if (_categoryBreakdown.isNotEmpty) ...[
                    _sectionTitle('Category Breakdown', isDark),
                    const SizedBox(height: 16),
                    _buildCategoryBreakdown(isDark),
                    const SizedBox(height: 28),
                  ],
                  _sectionTitle('Achievements', isDark),
                  const SizedBox(height: 16),
                  _buildAchievements(isDark),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : AppTheme.primaryCharcoal,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.cardDark : Colors.grey.shade100,
            ),
            child: Icon(Icons.insights_outlined, size: 56,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text('No Data Available', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.primaryCharcoal,
          )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start tracking products to unlock your carbon analytics and environmental impact insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500, height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(double avgScore, Color levelColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.cardDark, AppTheme.primarySlate.withValues(alpha: 0.5)]
              : [Colors.white, Colors.grey.shade50],
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
        boxShadow: [BoxShadow(
          color: levelColor.withValues(alpha: isDark ? 0.08 : 0.15),
          blurRadius: 24, offset: const Offset(0, 8),
        )],
      ),
      child: Column(
        children: [
          if (_user.footprintLevel == 'High')
            _buildBanner(Icons.warning_amber_rounded, 'High footprint detected. Try more eco-friendly products.', AppTheme.scorePoor),
          if (_user.footprintLevel == 'Low')
            _buildBanner(Icons.eco_rounded, 'Outstanding! You are an eco-warrior. 🌍', AppTheme.scoreExcellent),
          Row(
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppTheme.primarySlate : Colors.grey.shade50,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100, height: 100,
                      child: CircularProgressIndicator(
                        value: (avgScore / 100).clamp(0, 1),
                        strokeWidth: 10, strokeCap: StrokeCap.round,
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(levelColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(avgScore.toStringAsFixed(0), style: TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w900, color: levelColor, height: 1,
                        )),
                        Text('AVG CO₂', style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                          letterSpacing: 1,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_user.footprintLevel} Impact', style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: levelColor,
                    )),
                    const SizedBox(height: 14),
                    _statRow(Icons.inventory_2_rounded, 'Products', _user.totalPurchases.toString(), isDark),
                    const SizedBox(height: 6),
                    _statRow(Icons.cloud_rounded, 'Total CO₂e', '${_user.totalCarbonFootprint.toStringAsFixed(0)} kg', isDark),
                    const SizedBox(height: 6),
                    _statRow(Icons.document_scanner_rounded, 'Scans', _user.totalScans.toString(), isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
        ))),
        Text(value, style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : AppTheme.primaryCharcoal,
        )),
      ],
    );
  }

  Widget _buildImpactEquivalents(bool isDark) {
    final totalCarbon = _user.totalCarbonFootprint;
    final trees = (totalCarbon / 21.77).clamp(0, 9999);
    final carMiles = (totalCarbon * 2.31).clamp(0, 99999);
    final flights = (totalCarbon / 90).clamp(0, 999); // ~90 kg CO2 per hour of flight

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Footprint Equals...', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.primaryCharcoal,
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              _equivalentItem(Icons.park_rounded, '${trees.toStringAsFixed(1)}', 'trees/year\nto offset', AppTheme.scoreExcellent, isDark),
              const SizedBox(width: 12),
              _equivalentItem(Icons.directions_car_rounded, '${carMiles.toStringAsFixed(0)}', 'car miles\ndriven', AppTheme.scoreFair, isDark),
              const SizedBox(width: 12),
              _equivalentItem(Icons.flight_rounded, '${flights.toStringAsFixed(1)}', 'flight hours\navoided', AppTheme.accentCyan, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _equivalentItem(IconData icon, String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.primaryCharcoal,
          )),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            height: 1.3,
          )),
        ],
      ),
    );
  }

  Widget _buildGamificationSection(bool isDark) {
    final nextMilestone = _getNextMilestone(_user.totalPurchases);
    final progress = _user.totalPurchases / nextMilestone;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Next Milestone', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.primaryCharcoal,
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_user.totalPurchases} / $nextMilestone',
                  style: const TextStyle(color: AppTheme.accentEmerald, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentEmerald),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${nextMilestone - _user.totalPurchases} more products to unlock the next badge! 🎯',
            style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  int _getNextMilestone(int current) {
    if (current < 10) return 10;
    if (current < 50) return 50;
    if (current < 100) return 100;
    return ((current ~/ 100) + 1) * 100;
  }

  Widget _buildMonthlyChart(bool isDark) {
    if (_monthlyData.isEmpty) return const SizedBox.shrink();
    final maxY = _monthlyData.map((d) => (d['totalCarbon'] as double)).reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 24, right: 16, left: 16, bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxY == 0 ? 10 : maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: isDark ? Colors.white : AppTheme.primaryCharcoal,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem('${rod.toY.toStringAsFixed(1)} kg',
                  TextStyle(color: isDark ? AppTheme.primaryCharcoal : Colors.white, fontWeight: FontWeight.bold));
              },
            ),
          ),
          barGroups: _monthlyData.asMap().entries.map((entry) {
            final value = entry.value['totalCarbon'] as double;
            final color = AppTheme.getCarbonScoreColor(value / (entry.value['itemCount'] as int));
            return BarChartGroupData(
              x: entry.key,
              barRods: [BarChartRodData(
                toY: value,
                gradient: LinearGradient(colors: [color.withValues(alpha: 0.5), color],
                    begin: Alignment.bottomCenter, end: Alignment.topCenter),
                width: 22, borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true, toY: maxY == 0 ? 10 : maxY,
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
                ),
              )],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _monthlyData.length) return const SizedBox.shrink();
                final parts = _monthlyData[value.toInt()]['month'].toString().split('/');
                const names = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
                return Padding(padding: const EdgeInsets.only(top: 8),
                  child: Text(names[int.parse(parts[0]) - 1],
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)));
              },
            )),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true, drawVerticalLine: false,
            horizontalInterval: (maxY / 4) == 0 ? 1 : (maxY / 4),
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
              strokeWidth: 1, dashArray: [4, 4]),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(bool isDark) {
    if (_categoryBreakdown.isEmpty) return const SizedBox.shrink();
    final total = _categoryBreakdown.values.fold(0.0, (a, b) => a + b);
    final sorted = _categoryBreakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final colors = [AppTheme.accentEmerald, AppTheme.accentCyan, AppTheme.scoreFair, AppTheme.scorePoor, Colors.deepPurpleAccent, Colors.pinkAccent];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final cat = entry.value.key;
          final val = entry.value.value;
          final pct = total > 0 ? (val / total * 100) : 0;
          final color = colors[entry.key % colors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(width: 12, height: 12,
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 10),
                      Text(cat, style: TextStyle(fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                    ]),
                    Text('${val.toStringAsFixed(1)} kg (${pct.toStringAsFixed(0)}%)',
                        style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                            fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievements(bool isDark) {
    final all = [
      {'name': 'First Scan', 'icon': Icons.celebration_rounded, 'desc': 'Tracked 1 product'},
      {'name': 'Eco Explorer', 'icon': Icons.explore_rounded, 'desc': 'Tracked 10 products'},
      {'name': 'Sustainability Champ', 'icon': Icons.workspace_premium_rounded, 'desc': 'Tracked 50 products'},
      {'name': 'Green Guardian', 'icon': Icons.shield_rounded, 'desc': 'Tracked 100 products'},
      {'name': 'Low Impact Hero', 'icon': Icons.eco_rounded, 'desc': 'Low footprint maintained'},
    ];

    return Wrap(
      spacing: 12, runSpacing: 12,
      children: all.map((a) {
        final earned = _user.achievements.contains(a['name']);
        return Container(
          width: (MediaQuery.of(context).size.width - 40 - 12) / 2,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          decoration: BoxDecoration(
            color: earned
                ? AppTheme.accentEmerald.withValues(alpha: isDark ? 0.1 : 0.08)
                : (isDark ? AppTheme.cardDark : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: earned
                  ? AppTheme.accentEmerald.withValues(alpha: 0.3)
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: earned
                      ? AppTheme.accentEmerald.withValues(alpha: 0.15)
                      : (isDark ? AppTheme.primarySlate : Colors.grey.shade200),
                  shape: BoxShape.circle,
                ),
                child: Icon(a['icon'] as IconData, size: 24,
                    color: earned ? AppTheme.accentEmerald : Colors.grey.shade500),
              ),
              const SizedBox(height: 12),
              Text(a['name'] as String, textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                      color: earned
                          ? (isDark ? Colors.white : AppTheme.primaryCharcoal)
                          : Colors.grey.shade500)),
              const SizedBox(height: 4),
              Text(a['desc'] as String, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11,
                      color: earned
                          ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                          : Colors.grey.shade400)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Low': return AppTheme.scoreExcellent;
      case 'Medium': return AppTheme.scoreFair;
      case 'High': return AppTheme.scorePoor;
      default: return Colors.grey;
    }
  }
}
