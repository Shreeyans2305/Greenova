import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service_provider.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../../data/models/purchase_record_model.dart';
import '../../../data/models/sustainability_report_model.dart';
import '../../theme/app_theme.dart';

class SustainabilityReportScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? reportData;
  const SustainabilityReportScreen({super.key, this.reportData});

  @override
  ConsumerState<SustainabilityReportScreen> createState() => _SustainabilityReportScreenState();
}

class _SustainabilityReportScreenState extends ConsumerState<SustainabilityReportScreen> {
  late SustainabilityReport report;
  String _selectedCategory = 'General';
  bool _isAdding = false;

  // Alternatives state
  bool _loadingAlternatives = false;
  bool _alternativesFetched = false;
  List<Map<String, dynamic>> _alternatives = [];
  String _generalTip = '';

  final _categories = ['Food & Beverages', 'Personal Care', 'Household', 'Electronics', 'Clothing', 'General'];

  bool get _needsAlternatives =>
      report.sustainabilityGrade == 'D' ||
      report.sustainabilityGrade == 'F' ||
      report.carbonScore >= 65;

  @override
  void initState() {
    super.initState();
    if (widget.reportData != null && widget.reportData!['report'] != null) {
      report = SustainabilityReport.fromJson(widget.reportData!['report'] as Map<String, dynamic>);
    } else {
      report = SustainabilityReport(
        id: 'empty', productName: 'Unknown Product', carbonScore: 50,
        sustainabilityGrade: 'C', positiveFactors: [], negativeFactors: [],
        recommendations: [], detailedAnalysis: 'No data available',
        searchType: 'unknown', isGeneralized: false, generatedAt: DateTime.now(),
      );
    }
    // Auto-fetch alternatives for unsustainable products
    if (_needsAlternatives) {
      _fetchAlternatives();
    }
  }

  Future<void> _fetchAlternatives() async {
    if (_alternativesFetched || _loadingAlternatives) return;
    setState(() => _loadingAlternatives = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.getAlternatives(
        productName: report.productName,
        carbonScore: report.carbonScore,
        sustainabilityGrade: report.sustainabilityGrade,
        negativeFactors: report.negativeFactors,
      );

      final alts = (result['alternatives'] as List<dynamic>?)
          ?.map((a) => a as Map<String, dynamic>)
          .toList() ?? [];

      if (mounted) {
        setState(() {
          _alternatives = alts;
          _generalTip = result['generalTip'] ?? '';
          _alternativesFetched = true;
          _loadingAlternatives = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingAlternatives = false;
          _alternativesFetched = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppTheme.getGradeColor(report.sustainabilityGrade);
    final scoreColor = AppTheme.getCarbonScoreColor(report.carbonScore);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: isDark
                        ? [AppTheme.primarySlate, AppTheme.surfaceDark]
                        : [AppTheme.primaryCharcoal, AppTheme.primarySlate],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: gradeColor.withValues(alpha: 0.4), blurRadius: 24)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(report.sustainabilityGrade, style: TextStyle(
                              fontSize: 44, fontWeight: FontWeight.w900, color: gradeColor)),
                            Text('Grade', style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(report.productName, textAlign: TextAlign.center, maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      if (report.brand != null)
                        Text(report.brand!, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Carbon Score
                _buildCard(isDark, child: Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Carbon Footprint Score', style: TextStyle(fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                        const SizedBox(height: 4),
                        Text('Lower is better', style: TextStyle(
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500, fontSize: 13)),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(children: [
                        Text(report.carbonScore.toStringAsFixed(0), style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900, color: scoreColor)),
                        Text('CO₂e', style: TextStyle(color: scoreColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                )),
                const SizedBox(height: 14),

                // Eco Equivalents
                if (report.treesNeeded != null || report.carMiles != null)
                  _buildCard(isDark, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.nature_rounded, color: AppTheme.accentEmerald, size: 20),
                        const SizedBox(width: 8),
                        Text('Environmental Equivalents', style: TextStyle(fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                      ]),
                      const SizedBox(height: 14),
                      Wrap(spacing: 16, runSpacing: 10, children: [
                        if (report.treesNeeded != null)
                          _ecoChip(Icons.park_rounded, '${report.treesNeeded!.toStringAsFixed(2)} trees', AppTheme.scoreExcellent, isDark),
                        if (report.carMiles != null)
                          _ecoChip(Icons.directions_car_rounded, '${report.carMiles!.toStringAsFixed(1)} car miles', AppTheme.scoreFair, isDark),
                        if (report.plasticBags != null)
                          _ecoChip(Icons.shopping_bag_rounded, '${report.plasticBags} bags', AppTheme.scorePoor, isDark),
                        if (report.lightBulbHours != null)
                          _ecoChip(Icons.lightbulb_rounded, '${report.lightBulbHours}h bulb', AppTheme.accentCyan, isDark),
                      ]),
                    ],
                  )),

                if (report.isGeneralized) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Icon(Icons.info_outline_rounded, color: AppTheme.accentCyan, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Generalized report for this product category',
                          style: TextStyle(color: AppTheme.accentCyan, fontSize: 13))),
                    ]),
                  ),
                ],
                const SizedBox(height: 14),

                // ⚠️ HIGH IMPACT WARNING for D/F grades
                if (_needsAlternatives)
                  _buildHighImpactWarning(isDark),

                // Positive Factors
                if (report.positiveFactors.isNotEmpty)
                  _buildFactors('Positive Factors', report.positiveFactors, Icons.check_circle_rounded, AppTheme.scoreExcellent, isDark),
                const SizedBox(height: 14),

                // Negative Factors
                if (report.negativeFactors.isNotEmpty)
                  _buildFactors('Areas of Concern', report.negativeFactors, Icons.warning_rounded, AppTheme.scorePoor, isDark),
                const SizedBox(height: 14),

                // 🌱 ECO-FRIENDLY ALTERNATIVES SECTION
                if (_needsAlternatives)
                  _buildAlternativesSection(isDark),

                // Recommendations
                if (report.recommendations.isNotEmpty)
                  _buildCard(isDark, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.lightbulb_rounded, color: AppTheme.scoreFair, size: 20),
                        const SizedBox(width: 8),
                        Text('Recommendations', style: TextStyle(fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                      ]),
                      const SizedBox(height: 12),
                      ...report.recommendations.asMap().entries.map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.scoreFair.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 22, height: 22,
                            decoration: const BoxDecoration(color: AppTheme.scoreFair, shape: BoxShape.circle),
                            child: Center(child: Text('${e.key + 1}', style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.value, style: TextStyle(
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, height: 1.4))),
                        ]),
                      )),
                    ],
                  )),
                const SizedBox(height: 14),

                // Detailed Analysis
                if (report.detailedAnalysis.isNotEmpty)
                  _buildCard(isDark, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.analytics_rounded, color: AppTheme.accentCyan, size: 20),
                        const SizedBox(width: 8),
                        Text('Detailed Analysis', style: TextStyle(fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                      ]),
                      const SizedBox(height: 12),
                      Text(report.detailedAnalysis, style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5)),
                    ],
                  )),
                const SizedBox(height: 20),

                // Add to purchase history
                _buildCard(isDark, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Track This Product', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,
                        color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                    const SizedBox(height: 6),
                    Text('Add to your purchase history to monitor impact', style: TextStyle(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(height: 14),
                    Wrap(spacing: 8, runSpacing: 8, children: _categories.map((c) {
                      final sel = c == _selectedCategory;
                      return ChoiceChip(
                        label: Text(c),
                        selected: sel,
                        onSelected: (s) => setState(() => _selectedCategory = c),
                        selectedColor: AppTheme.accentEmerald.withValues(alpha: 0.15),
                        labelStyle: TextStyle(color: sel ? AppTheme.accentEmerald : null, fontSize: 12),
                      );
                    }).toList()),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isAdding ? null : _addToPurchase,
                        icon: _isAdding
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.add_shopping_cart_rounded),
                        label: Text(_isAdding ? 'Adding...' : 'Add to History'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.accentEmerald,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ----------- HIGH IMPACT WARNING BANNER -----------
  Widget _buildHighImpactWarning(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.scoreBad.withValues(alpha: 0.12),
            AppTheme.scorePoor.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: AppTheme.scoreBad.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.scoreBad.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppTheme.scoreBad, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'High Environmental Impact',
                  style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14,
                    color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This product has a significant carbon footprint. Consider the eco-friendly alternatives below.',
                  style: TextStyle(
                    fontSize: 12, height: 1.3,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------- ALTERNATIVES SECTION -----------
  Widget _buildAlternativesSection(bool isDark) {
    return Column(
      children: [
        _buildCard(isDark, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.scoreExcellent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: AppTheme.scoreExcellent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Eco-Friendly Alternatives', style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16,
                  color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                )),
              ),
              if (!_alternativesFetched && !_loadingAlternatives)
                GestureDetector(
                  onTap: _fetchAlternatives,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.accentEmerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Load', style: TextStyle(
                      color: AppTheme.accentEmerald, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ),
            ]),
            const SizedBox(height: 4),
            Text(
              'Better options for the planet',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),

            if (_loadingAlternatives)
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.accentEmerald,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Finding greener alternatives with AI...', style: TextStyle(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                      fontSize: 13,
                    )),
                  ],
                ),
              ),

            if (_alternativesFetched && _alternatives.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Text('No alternatives found. Try searching manually.',
                  style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
              ),

            if (_alternatives.isNotEmpty)
              ..._alternatives.asMap().entries.map((entry) => _buildAlternativeCard(entry.value, entry.key, isDark)),

            if (_generalTip.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentEmerald.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentEmerald.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: AppTheme.accentEmerald, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_generalTip, style: TextStyle(
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        fontSize: 13, height: 1.4, fontStyle: FontStyle.italic,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ],
        )),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildAlternativeCard(Map<String, dynamic> alt, int index, bool isDark) {
    final name = alt['name'] ?? 'Alternative ${index + 1}';
    final brand = alt['brand'] ?? '';
    final score = (alt['estimatedCarbonScore'] as num?)?.toDouble() ?? 30;
    final grade = alt['sustainabilityGrade'] ?? 'B';
    final whyBetter = alt['whyBetter'] ?? '';
    final benefits = (alt['keyBenefits'] as List<dynamic>?)?.cast<String>() ?? [];
    final gradeColor = AppTheme.getGradeColor(grade);
    final scoreDiff = report.carbonScore - score;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark
            ? AppTheme.primarySlate.withValues(alpha: 0.5)
            : Colors.grey.shade50,
        border: Border.all(
          color: AppTheme.accentEmerald.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Grade circle
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gradeColor.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(grade, style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: gradeColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                      )),
                    if (brand.isNotEmpty)
                      Text(brand, style: TextStyle(fontSize: 12,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
                  ],
                ),
              ),
              // Score comparison
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${score.toStringAsFixed(0)} CO₂', style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14,
                    color: AppTheme.getCarbonScoreColor(score),
                  )),
                  if (scoreDiff > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.scoreExcellent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '↓ ${scoreDiff.toStringAsFixed(0)}% less',
                        style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppTheme.scoreExcellent,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (whyBetter.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(whyBetter, style: TextStyle(
              fontSize: 13, height: 1.3,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            )),
          ],
          if (benefits.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 4, children: benefits.map((b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accentEmerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(b, style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentEmerald)),
            )).toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }

  Widget _ecoChip(IconData icon, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  Widget _buildFactors(String title, List<String> factors, IconData icon, Color color, bool isDark) {
    return _buildCard(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
        ]),
        const SizedBox(height: 12),
        ...factors.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon == Icons.check_circle_rounded ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
                size: 16, color: color.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Expanded(child: Text(f, style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.4))),
          ]),
        )),
      ],
    ));
  }

  Future<void> _addToPurchase() async {
    setState(() => _isAdding = true);
    try {
      final purchase = PurchaseRecord.fromReport(report, _selectedCategory);
      await HiveBoxes.addPurchase(purchase);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to purchase history! ✅'), backgroundColor: AppTheme.accentEmerald),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.scoreBad),
        );
      }
    } finally {
      setState(() => _isAdding = false);
    }
  }
}
