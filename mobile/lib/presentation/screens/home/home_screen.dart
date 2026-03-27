import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = HiveBoxes.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Hero Header ──
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
              actions: [
                Consumer(
                  builder: (context, ref, _) {
                    final themeMode = ref.watch(themeProvider);
                    final isCurrentlyDark = themeMode == ThemeMode.dark ||
                        (themeMode == ThemeMode.system &&
                            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
                    return IconButton(
                      icon: Icon(
                        isCurrentlyDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(context),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco_rounded, color: AppTheme.accentEmerald, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'GreenNova',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppTheme.primaryDeep, AppTheme.surfaceDark]
                          : [AppTheme.primaryCharcoal, AppTheme.primarySlate],
                    ),
                  ),
                ),
              ),
            ),

            // ── Content ──
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Welcome / Impact Card
                  _buildImpactCard(context, user, isDark),
                  const SizedBox(height: 28),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, isDark),
                  const SizedBox(height: 28),

                  // Environmental Impact
                  Text(
                    'Your Environmental Impact',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildImpactEquivalents(context, user, isDark),
                  const SizedBox(height: 28),

                  // Stats
                  Text(
                    'Your Stats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsCards(context, user, isDark),
                  const SizedBox(height: 28),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Scans',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                        ),
                      ),
                      if (HiveBoxes.getAllPurchases().isNotEmpty)
                        TextButton(
                          onPressed: () => context.push(AppRoutes.history),
                          child: const Text('View All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRecentActivity(context, isDark),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context, dynamic user, bool isDark) {
    Color levelColor;
    IconData levelIcon;
    String message;
    final level = user.footprintLevel;

    switch (level) {
      case 'Low':
        levelColor = AppTheme.scoreExcellent;
        levelIcon = Icons.eco_rounded;
        message = 'Excellent! Your carbon footprint is impressively low.';
        break;
      case 'Medium':
        levelColor = AppTheme.scoreFair;
        levelIcon = Icons.trending_flat_rounded;
        message = 'Making progress! Consider more eco-friendly choices.';
        break;
      case 'High':
        levelColor = AppTheme.scorePoor;
        levelIcon = Icons.warning_amber_rounded;
        message = 'Your footprint is high. Let\'s work on reducing it!';
        break;
      default:
        levelColor = AppTheme.accentEmerald;
        levelIcon = Icons.explore_rounded;
        message = 'Start scanning products to track your environmental impact.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppTheme.cardDark, AppTheme.primarySlate.withValues(alpha: 0.5)]
              : [Colors.white, Colors.grey.shade50],
        ),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: levelColor.withValues(alpha: isDark ? 0.1 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(levelIcon, color: levelColor, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$level Impact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: levelColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.search_rounded,
                label: 'Search',
                subtitle: 'Find eco products',
                color: AppTheme.accentEmerald,
                isDark: isDark,
                onTap: () => context.go(AppRoutes.search),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.compare_arrows_rounded,
                label: 'Compare',
                subtitle: 'Side-by-side',
                color: AppTheme.accentCyan,
                isDark: isDark,
                onTap: () => context.go(AppRoutes.compare),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.camera_alt_rounded,
          label: 'Scan Product',
          subtitle: 'Capture ingredients for AI analysis by Gemma',
          color: AppTheme.scoreFair,
          isDark: isDark,
          onTap: () => context.push(AppRoutes.scanner),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildImpactEquivalents(BuildContext context, dynamic user, bool isDark) {
    final totalCarbon = user.totalCarbonFootprint;
    // Rough estimates for environmental equivalents
    final treesNeeded = (totalCarbon / 21.77).clamp(0, 9999); // 1 tree absorbs ~21.77 kg CO2/year
    final carMiles = (totalCarbon * 2.31).clamp(0, 99999); // ~0.433 kg CO2 per mile
    final bulbHours = (totalCarbon * 1000 / 0.042).clamp(0, 999999); // ~0.042 kg CO2 per kWh, 60W bulb

    if (totalCarbon == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? AppTheme.cardDark : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.nature_people_rounded, size: 48,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No impact data yet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Scan products to see your environmental footprint',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _ImpactCard(
            icon: Icons.park_rounded,
            value: treesNeeded.toStringAsFixed(1),
            label: 'Trees needed\nto offset',
            color: AppTheme.scoreExcellent,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ImpactCard(
            icon: Icons.directions_car_rounded,
            value: carMiles.toStringAsFixed(0),
            label: 'Equivalent\ncar miles',
            color: AppTheme.scoreFair,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ImpactCard(
            icon: Icons.lightbulb_rounded,
            value: _formatNumber(bulbHours),
            label: 'Bulb hours\nequivalent',
            color: AppTheme.accentCyan,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  String _formatNumber(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  Widget _buildStatsCards(BuildContext context, dynamic user, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_bag_rounded,
            value: user.totalPurchases.toString(),
            label: 'Products',
            color: AppTheme.accentEmerald,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.document_scanner_rounded,
            value: user.totalScans.toString(),
            label: 'Scans',
            color: AppTheme.accentCyan,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events_rounded,
            value: user.achievements.length.toString(),
            label: 'Badges',
            color: AppTheme.scoreFair,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, bool isDark) {
    final purchases = HiveBoxes.getAllPurchases().take(3).toList();

    if (purchases.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? AppTheme.cardDark : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.eco_rounded, size: 48,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No scans yet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search for products to get sustainability reports!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: purchases.map((purchase) {
        final gradeColor = AppTheme.getGradeColor(purchase.sustainabilityGrade);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? AppTheme.cardDark : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  purchase.sustainabilityGrade,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: gradeColor,
                  ),
                ),
              ),
            ),
            title: Text(
              purchase.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.primaryCharcoal,
              ),
            ),
            subtitle: Text(
              purchase.category,
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${purchase.carbonScore.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.getCarbonScoreColor(purchase.carbonScore),
                  ),
                ),
                Text(
                  'CO₂',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Quick Action Card ───
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final bool fullWidth;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(fullWidth ? 18 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? AppTheme.cardDark : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
          ),
        ),
        child: fullWidth
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                        )),
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                        )),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 14),
                  Text(label, style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                  )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  )),
                ],
              ),
      ),
    );
  }
}

// ─── Stat Card ───
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.primaryCharcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Impact Equivalent Card ───
class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _ImpactCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.primaryCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
