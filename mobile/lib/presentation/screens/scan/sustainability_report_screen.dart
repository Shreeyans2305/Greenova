import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  bool _isAddingToPurchase = false;

  final List<String> _categories = [
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
    if (widget.reportData != null && widget.reportData!['report'] != null) {
      report = SustainabilityReport.fromJson(
        widget.reportData!['report'] as Map<String, dynamic>,
      );
    } else {
      // Default empty report
      report = SustainabilityReport(
        id: 'empty',
        productName: 'Unknown Product',
        carbonScore: 50,
        sustainabilityGrade: 'C',
        positiveFactors: [],
        negativeFactors: [],
        recommendations: [],
        detailedAnalysis: 'No data available',
        searchType: 'unknown',
        isGeneralized: false,
        generatedAt: DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppTheme.getGradeColor(report.sustainabilityGrade);
    final scoreColor = AppTheme.getCarbonScoreColor(report.carbonScore);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient App Bar with Score
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: gradeColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      gradeColor,
                      gradeColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Carbon Score Display
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              report.sustainabilityGrade,
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: gradeColor,
                              ),
                            ),
                            Text(
                              'Grade',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Product Name
                      Text(
                        report.productName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (report.brand != null)
                        Text(
                          report.brand!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Carbon Score Card
                _buildScoreCard(scoreColor),
                const SizedBox(height: 16),

                // Report Type Badge
                if (report.isGeneralized)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This is a generalized report for this product category',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Positive Factors
                _buildFactorsCard(
                  'Positive Factors',
                  report.positiveFactors,
                  Icons.check_circle,
                  AppTheme.scoreExcellent,
                ),
                const SizedBox(height: 16),

                // Negative Factors
                _buildFactorsCard(
                  'Areas of Concern',
                  report.negativeFactors,
                  Icons.warning,
                  AppTheme.scorePoor,
                ),
                const SizedBox(height: 16),

                // Recommendations
                _buildRecommendationsCard(),
                const SizedBox(height: 16),

                // Detailed Analysis
                if (report.detailedAnalysis.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.analytics, color: AppTheme.primaryGreen),
                              SizedBox(width: 8),
                              Text(
                                'Detailed Analysis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            report.detailedAnalysis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Add to Purchase History Button
                _buildAddToPurchaseButton(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(Color scoreColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carbon Footprint Score',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lower is better',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scoreColor.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    report.carbonScore.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    'CO2e',
                    style: TextStyle(color: scoreColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorsCard(
    String title,
    List<String> factors,
    IconData icon,
    Color color,
  ) {
    if (factors.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...factors.map((factor) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon == Icons.check_circle ? Icons.add_circle : Icons.remove_circle,
                    size: 16,
                    color: color.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      factor,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    if (report.recommendations.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.accentYellow),
                SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...report.recommendations.asMap().entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentYellow,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToPurchaseButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add to Purchase History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track this product to monitor your carbon footprint',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Category Selector
            const Text(
              'Category:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryGreen : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAddingToPurchase ? null : _addToPurchaseHistory,
                icon: _isAddingToPurchase
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_shopping_cart),
                label: Text(
                  _isAddingToPurchase ? 'Adding...' : 'Add to History',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToPurchaseHistory() async {
    setState(() => _isAddingToPurchase = true);

    try {
      final purchase = PurchaseRecord.fromReport(report, _selectedCategory);
      await HiveBoxes.addPurchase(purchase);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to purchase history!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isAddingToPurchase = false);
    }
  }
}
