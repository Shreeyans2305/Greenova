import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/services/ai_service_provider.dart';
import '../../theme/app_theme.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final TextEditingController _search1 = TextEditingController();
  final TextEditingController _search2 = TextEditingController();

  Map<String, dynamic>? _product1;
  Map<String, dynamic>? _product2;
  List<Map<String, dynamic>> _searchResults1 = [];
  List<Map<String, dynamic>> _searchResults2 = [];
  bool _searching1 = false;
  bool _searching2 = false;
  bool _comparing = false;
  Map<String, dynamic>? _comparisonResult;
  int _activeSlot = 0; // 0 = none, 1 or 2

  @override
  void dispose() {
    _search1.dispose();
    _search2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Products'),
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.cardDark, AppTheme.primarySlate.withValues(alpha: 0.5)]
                      : [Colors.white, Colors.grey.shade50],
                ),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.compare_arrows_rounded, size: 36,
                      color: AppTheme.accentCyan),
                  const SizedBox(height: 10),
                  Text(
                    'Compare Sustainability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search and select two products to compare their environmental impact',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product Slot 1
            _buildProductSlot(1, _product1, _search1, _searchResults1, _searching1, isDark),
            const SizedBox(height: 12),

            // VS indicator
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Product Slot 2
            _buildProductSlot(2, _product2, _search2, _searchResults2, _searching2, isDark),
            const SizedBox(height: 24),

            // Compare Button
            ElevatedButton.icon(
              onPressed: (_product1 != null && _product2 != null && !_comparing)
                  ? _compareProducts
                  : null,
              icon: _comparing
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.compare_arrows_rounded),
              label: Text(_comparing ? 'Analyzing...' : 'Compare with AI'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppTheme.accentEmerald,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark ? AppTheme.primarySlate : Colors.grey.shade200,
              ),
            ),

            // Comparison results
            if (_comparisonResult != null) ...[
              const SizedBox(height: 24),
              _buildComparisonResults(isDark),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSlot(
    int slot,
    Map<String, dynamic>? product,
    TextEditingController controller,
    List<Map<String, dynamic>> results,
    bool isSearching,
    bool isDark,
  ) {
    if (product != null) {
      return _buildSelectedProduct(slot, product, isDark);
    }

    final hasText = controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: _activeSlot == slot
              ? AppTheme.accentEmerald.withValues(alpha: 0.5)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
          width: _activeSlot == slot ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Product $slot',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Type a product name...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : hasText
                      ? IconButton(
                          icon: const Icon(Icons.search_rounded),
                          onPressed: () => _searchForSlot(slot, controller.text),
                          tooltip: 'Search database',
                        )
                      : null,
            ),
            onTap: () => setState(() => _activeSlot = slot),
            onChanged: (_) => setState(() {}),
            onSubmitted: (q) => _searchForSlot(slot, q),
            textInputAction: TextInputAction.search,
          ),

          // "Use this name" button — lets the user skip API search
          if (hasText && results.isEmpty && !isSearching) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _selectProduct(slot, {'name': controller.text.trim()}),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text('Use "${controller.text.trim()}"'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentEmerald,
                  side: BorderSide(color: AppTheme.accentEmerald.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],

          if (results.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppTheme.primarySlate : Colors.grey.shade50,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (ctx, i) {
                  final p = results[i];
                  return ListTile(
                    dense: true,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (p['imageSmallUrl'] ?? '').toString().isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: p['imageSmallUrl'],
                              width: 36, height: 36, fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _placeholderIcon(isDark),
                            )
                          : _placeholderIcon(isDark),
                    ),
                    title: Text(
                      p['name'] ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.primaryCharcoal),
                    ),
                    subtitle: Text(
                      p['brand'] ?? '',
                      maxLines: 1,
                      style: TextStyle(fontSize: 11,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                    ),
                    onTap: () => _selectProduct(slot, p),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholderIcon(bool isDark) {
    return Container(
      width: 36, height: 36,
      color: isDark ? AppTheme.primarySlate : Colors.grey.shade200,
      child: Icon(Icons.eco_rounded, size: 18,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
    );
  }

  Widget _buildSelectedProduct(int slot, Map<String, dynamic> product, bool isDark) {
    final name = product['name'] ?? 'Unknown';
    final brand = product['brand'] ?? '';
    final imageUrl = product['imageSmallUrl'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: AppTheme.accentEmerald.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl, width: 56, height: 56, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholderIcon(isDark),
                  )
                : _placeholderIcon(isDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                  ),
                ),
                if (brand.isNotEmpty)
                  Text(brand, style: TextStyle(fontSize: 12,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
            onPressed: () {
              setState(() {
                if (slot == 1) {
                  _product1 = null;
                  _searchResults1 = [];
                  _search1.clear();
                } else {
                  _product2 = null;
                  _searchResults2 = [];
                  _search2.clear();
                }
                _comparisonResult = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonResults(bool isDark) {
    final result = _comparisonResult!;
    final winner = result['winnerName'] ?? 'N/A';
    final summary = result['summary'] ?? '';
    final p1 = result['product1'] as Map<String, dynamic>? ?? {};
    final p2 = result['product2'] as Map<String, dynamic>? ?? {};
    final factors = result['comparisonFactors'] as List<dynamic>? ?? [];

    final p1Score = (p1['carbonScore'] as num?)?.toDouble() ?? 0;
    final p2Score = (p2['carbonScore'] as num?)?.toDouble() ?? 0;
    final p1Grade = (p1['sustainabilityGrade'] ?? '').toString();
    final p2Grade = (p2['sustainabilityGrade'] ?? '').toString();

    final p1HasData = p1Grade.isNotEmpty && p1Grade != 'N/A' && p1Score > 0;
    final p2HasData = p2Grade.isNotEmpty && p2Grade != 'N/A' && p2Score > 0;
    final p1Name = _product1?['name'] ?? 'Product 1';
    final p2Name = _product2?['name'] ?? 'Product 2';

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
          // Winner banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.accentEmerald.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.accentEmerald.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: AppTheme.accentEmerald),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏆 $winner wins!',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentEmerald,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Score comparison
          Row(
            children: [
              Expanded(
                child: p1HasData
                    ? _buildScoreColumn(p1Name, p1Score, p1Grade, isDark)
                    : _buildNoDataColumn(p1Name, isDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: p2HasData
                    ? _buildScoreColumn(p2Name, p2Score, p2Grade, isDark)
                    : _buildNoDataColumn(p2Name, isDark),
              ),
            ],
          ),

          // No data notice
          if (!p1HasData || !p2HasData) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.scoreFair.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.scoreFair.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.scoreFair, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Limited public data available for ${!p1HasData ? p1Name : p2Name}. Scores are AI estimates.',
                    style: TextStyle(fontSize: 12, color: AppTheme.scoreFair),
                  )),
                ],
              ),
            ),
          ],

          // Factor comparison bars
          if (factors.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Detailed Comparison',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.primaryCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Text(p1Name, textAlign: TextAlign.center,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentCyan))),
                const SizedBox(width: 40),
                Expanded(child: Text(p2Name, textAlign: TextAlign.center,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentEmerald))),
              ],
            ),
            const SizedBox(height: 12),
            ...factors.map((f) {
              final factor = f as Map<String, dynamic>;
              final name = factor['factor'] ?? '';
              final s1 = (factor['product1Score'] as num?)?.toDouble() ?? 5;
              final s2 = (factor['product2Score'] as num?)?.toDouble() ?? 5;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    )),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBar(s1, 10, AppTheme.accentCyan, isDark, rtl: true),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            'vs',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildBar(s2, 10, AppTheme.accentEmerald, isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(double value, double max, Color color, bool isDark, {bool rtl = false}) {
    final pct = (value / max).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: pct,
        minHeight: 8,
        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }

  Widget _buildNoDataColumn(String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppTheme.primarySlate.withValues(alpha: 0.5) : Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          const SizedBox(height: 12),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withValues(alpha: 0.15),
            ),
            child: Center(child: Icon(Icons.help_outline_rounded,
                size: 28, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
          ),
          const SizedBox(height: 8),
          Text('No Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildScoreColumn(String name, double score, String grade, bool isDark) {
    final gradeColor = AppTheme.getGradeColor(grade);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppTheme.primarySlate.withValues(alpha: 0.5) : Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gradeColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                grade,
                style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  color: gradeColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${score.toStringAsFixed(0)} CO₂',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppTheme.getCarbonScoreColor(score),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchForSlot(int slot, String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      if (slot == 1) _searching1 = true;
      else _searching2 = true;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final products = await aiService.searchProducts(query.trim());
      if (mounted) {
        setState(() {
          if (slot == 1) {
            _searchResults1 = products;
            _searching1 = false;
          } else {
            _searchResults2 = products;
            _searching2 = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (slot == 1) _searching1 = false;
          else _searching2 = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _selectProduct(int slot, Map<String, dynamic> product) {
    setState(() {
      if (slot == 1) {
        _product1 = product;
        _searchResults1 = [];
      } else {
        _product2 = product;
        _searchResults2 = [];
      }
      _activeSlot = 0;
      _comparisonResult = null;
    });
  }

  Future<void> _compareProducts() async {
    if (_product1 == null || _product2 == null) return;

    setState(() => _comparing = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.compareProducts(
        _product1!['name'] ?? 'Product 1',
        _product2!['name'] ?? 'Product 2',
        product1Data: _product1,
        product2Data: _product2,
      );
      if (mounted) {
        setState(() {
          _comparisonResult = result;
          _comparing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _comparing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comparison failed: $e'), backgroundColor: AppTheme.scoreBad),
        );
      }
    }
  }
}
