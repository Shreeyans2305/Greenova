import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service_provider.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../../data/models/search_history_model.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoadingProducts = false;
  List<Map<String, dynamic>> _productResults = [];
  List<SearchHistoryItem> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = HiveBoxes.getRecentSearches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for any product...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _productResults = []);
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _searchProducts,
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingProducts || _isSearching
                            ? null
                            : () => _searchProducts(_searchController.text),
                        icon: _isLoadingProducts
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.search_rounded, size: 20),
                        label: Text(_isLoadingProducts ? 'Searching...' : 'Find Products'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.science_rounded,
                          color: AppTheme.accentCyan,
                        ),
                        tooltip: 'Analyze Ingredients',
                        onPressed: () => _showIngredientDialog(context, isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Suggestions
          if (_productResults.isEmpty && !_isLoadingProducts)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Searches',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSuggestionChip('Nutella', isDark),
                      _buildSuggestionChip('Coca Cola', isDark),
                      _buildSuggestionChip('Organic Rice', isDark),
                      _buildSuggestionChip('Almond Milk', isDark),
                      _buildSuggestionChip('Green Tea', isDark),
                      _buildSuggestionChip('Olive Oil', isDark),
                    ],
                  ),
                ],
              ),
            ),

          // Loading
          if (_isLoadingProducts)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Searching Open Food Facts...'),
                ],
              ),
            ),

          // AI Search loading
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppTheme.accentEmerald),
                  const SizedBox(height: 16),
                  const Text('Analyzing sustainability with AI...'),
                ],
              ),
            ),

          // Product Results
          if (_productResults.isNotEmpty && !_isSearching)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _productResults.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_productResults.length} products found',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(Icons.auto_awesome_rounded, size: 16,
                                color: AppTheme.accentEmerald),
                            label: Text('AI Search',
                                style: TextStyle(color: AppTheme.accentEmerald)),
                            onPressed: () => _aiSearch(_searchController.text),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildProductCard(_productResults[index - 1], isDark);
                },
              ),
            ),

          // Recent searches (when no results)
          if (_productResults.isEmpty && !_isLoadingProducts && !_isSearching)
            Expanded(child: _buildRecentSearches(isDark)),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, bool isDark) {
    return ActionChip(
      label: Text(text),
      backgroundColor: isDark ? AppTheme.cardDark : Colors.grey.shade100,
      side: BorderSide.none,
      onPressed: () {
        _searchController.text = text;
        _searchProducts(text);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    final name = product['name'] ?? 'Unknown';
    final brand = product['brand'] ?? '';
    final imageUrl = product['imageSmallUrl'] ?? '';
    final ecoscore = product['ecoscoreGrade'] ?? '';
    final nutriscore = product['nutriscoreGrade'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _analyzeProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 64, height: 64,
                          color: isDark ? AppTheme.primarySlate : Colors.grey.shade100,
                          child: Icon(Icons.image_rounded,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 64, height: 64,
                          color: isDark ? AppTheme.primarySlate : Colors.grey.shade100,
                          child: Icon(Icons.eco_rounded,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                        ),
                      )
                    : Container(
                        width: 64, height: 64,
                        color: isDark ? AppTheme.primarySlate : Colors.grey.shade100,
                        child: Icon(Icons.eco_rounded,
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                      ),
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
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                      ),
                    ),
                    if (brand.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        brand,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (ecoscore.isNotEmpty) _buildScoreBadge('Eco', ecoscore, isDark),
                        if (nutriscore.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _buildScoreBadge('Nutri', nutriscore, isDark),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(String label, String grade, bool isDark) {
    final color = AppTheme.getGradeColor(grade.toUpperCase() == 'E' ? 'F' : grade.toUpperCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${grade.toUpperCase()}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 56,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Search for any product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Get real product data and AI sustainability analysis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                child: Text('Clear',
                    style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final item = _recentSearches[index];
              return ListTile(
                leading: Icon(
                  item.searchType == 'image' ? Icons.image_rounded : Icons.search_rounded,
                  color: AppTheme.accentEmerald,
                ),
                title: Text(item.query),
                subtitle: Text(
                  _formatDate(item.searchedAt),
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                onTap: () {
                  _searchController.text = item.query;
                  _searchProducts(item.query);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoadingProducts = true;
      _productResults = [];
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final products = await aiService.searchProducts(query.trim());
      if (mounted) {
        setState(() {
          _productResults = products;
          _isLoadingProducts = false;
        });
        // If no products found, fall back to AI search
        if (products.isEmpty) {
          _aiSearch(query);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
        // Fall back to AI search on error
        _aiSearch(query);
      }
    }
  }

  Future<void> _analyzeProduct(Map<String, dynamic> product) async {
    final name = product['name'] ?? 'Product';
    final ingredients = product['ingredients'] ?? '';
    final brand = product['brand'] ?? '';

    setState(() => _isSearching = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final query = ingredients.isNotEmpty
          ? ingredients
          : '$name ${brand.isNotEmpty ? "by $brand" : ""}';
      final report = await aiService.analyzeIngredients(
        query,
        productName: name,
      );

      await HiveBoxes.addSearchHistory(SearchHistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        query: name,
        searchType: 'product',
        searchedAt: DateTime.now(),
        reportId: report.id,
      ));
      await HiveBoxes.cacheReport(report);

      if (mounted) {
        context.push(AppRoutes.sustainabilityReport, extra: {'report': report.toJson()});
        _loadRecentSearches();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e'), backgroundColor: AppTheme.scoreBad),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _aiSearch(String query) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search term')),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final report = await aiService.searchByText(query.trim());

      await HiveBoxes.addSearchHistory(SearchHistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        query: query.trim(),
        searchType: 'text',
        searchedAt: DateTime.now(),
        reportId: report.id,
      ));
      await HiveBoxes.cacheReport(report);

      if (mounted) {
        context.push(AppRoutes.sustainabilityReport, extra: {'report': report.toJson()});
        _loadRecentSearches();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e'), backgroundColor: AppTheme.scoreBad),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showIngredientDialog(BuildContext context, bool isDark) {
    final ingredientsController = TextEditingController();
    final productNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Analyze Ingredients',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.primaryCharcoal,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name (optional)',
                hintText: 'e.g., Organic Shampoo',
                prefixIcon: Icon(Icons.label_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ingredientsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ingredients List',
                hintText: 'Enter ingredients separated by commas...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.list_rounded),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final text = ingredientsController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx);
                _analyzeIngredients(text, productNameController.text.trim());
              },
              icon: const Icon(Icons.eco_rounded),
              label: const Text('Analyze Sustainability'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.accentEmerald,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeIngredients(String ingredients, String productName) async {
    setState(() => _isSearching = true);
    try {
      final aiService = ref.read(aiServiceProvider);
      final name = productName.isNotEmpty ? productName : 'Product';
      final report = await aiService.analyzeIngredients(ingredients, productName: name);
      await HiveBoxes.cacheReport(report);

      final user = HiveBoxes.currentUser.incrementScans();
      await HiveBoxes.updateUser(user);

      if (mounted) {
        context.push(AppRoutes.sustainabilityReport, extra: {'report': report.toJson()});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.scoreBad),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _clearHistory() async {
    await HiveBoxes.clearSearchHistory();
    _loadRecentSearches();
  }
}
