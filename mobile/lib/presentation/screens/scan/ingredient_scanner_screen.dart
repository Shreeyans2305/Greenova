import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service_provider.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../theme/app_theme.dart';

class IngredientScannerScreen extends ConsumerStatefulWidget {
  const IngredientScannerScreen({super.key});

  @override
  ConsumerState<IngredientScannerScreen> createState() =>
      _IngredientScannerScreenState();
}

class _IngredientScannerScreenState
    extends ConsumerState<IngredientScannerScreen> {
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _ingredientsController.dispose();
    _productNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Analysis'),
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_rounded,
                size: 80,
                color: AppTheme.accentCyan,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              kIsWeb ? 'Enter Ingredients' : 'Scan or Enter Ingredients',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.primaryCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the product ingredients to analyze sustainability',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name (optional)',
                hintText: 'e.g., Organic Shampoo',
                prefixIcon: Icon(Icons.label_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ingredientsController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Ingredients List',
                hintText: 'Enter ingredients separated by commas...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 100),
                  child: Icon(Icons.list_rounded),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _analyzeIngredients,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.eco_rounded),
              label: Text(_isProcessing ? 'Analyzing...' : 'Analyze Sustainability'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.accentEmerald,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text('Try these examples:', style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.primaryCharcoal,
            )),
            const SizedBox(height: 12),
            _buildExampleCard('Natural Soap',
                'Coconut Oil, Olive Oil, Shea Butter, Essential Oils, Vitamin E', isDark),
            const SizedBox(height: 8),
            _buildExampleCard('Processed Snack',
                'Wheat Flour, Palm Oil, Sugar, Salt, Artificial Flavors, Preservatives', isDark),
            const SizedBox(height: 8),
            _buildExampleCard('Organic Juice',
                'Organic Apple Juice, Organic Grape Juice, Ascorbic Acid', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(String name, String ingredients, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: () {
          _productNameController.text = name;
          _ingredientsController.text = ingredients;
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
              const SizedBox(height: 4),
              Text(ingredients, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _analyzeIngredients() async {
    final ingredients = _ingredientsController.text.trim();
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ingredients')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final productName = _productNameController.text.trim().isNotEmpty
          ? _productNameController.text.trim()
          : 'Product';

      final report = await aiService.analyzeIngredients(
        ingredients,
        productName: productName,
      );

      await HiveBoxes.cacheReport(report);
      final user = HiveBoxes.currentUser.incrementScans();
      await HiveBoxes.updateUser(user);

      if (mounted) {
        context.push(
          AppRoutes.sustainabilityReport,
          extra: {'report': report.toJson()},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.scoreBad),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
