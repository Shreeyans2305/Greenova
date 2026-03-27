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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Analysis'),
        backgroundColor: AppTheme.secondaryTeal,
        foregroundColor: Colors.white,
      ),
      body: _buildManualInputUI(),
    );
  }

  Widget _buildManualInputUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.secondaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner,
              size: 80,
              color: AppTheme.secondaryTeal,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            kIsWeb ? 'Enter Ingredients' : 'Scan or Enter Ingredients',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the product ingredients to analyze sustainability',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Product Name Input
          TextField(
            controller: _productNameController,
            decoration: InputDecoration(
              labelText: 'Product Name (optional)',
              hintText: 'e.g., Organic Shampoo',
              prefixIcon: const Icon(Icons.label),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),

          // Ingredients Input
          TextField(
            controller: _ingredientsController,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Ingredients List',
              hintText:
                  'Enter ingredients separated by commas...\ne.g., Water, Coconut Oil, Aloe Vera, Vitamin E',
              alignLabelWithHint: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: Icon(Icons.list),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),

          // Analyze Button
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _analyzeIngredients,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.eco),
            label:
                Text(_isProcessing ? 'Analyzing...' : 'Analyze Sustainability'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Example Products
          const Text(
            'Try these examples:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            'Natural Soap',
            'Coconut Oil, Olive Oil, Shea Butter, Essential Oils, Vitamin E',
          ),
          const SizedBox(height: 8),
          _buildExampleCard(
            'Processed Snack',
            'Wheat Flour, Palm Oil, Sugar, Salt, Artificial Flavors, Preservatives, MSG, Food Coloring',
          ),
          const SizedBox(height: 8),
          _buildExampleCard(
            'Organic Juice',
            'Organic Apple Juice, Organic Grape Juice, Ascorbic Acid',
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String name, String ingredients) {
    return Card(
      child: InkWell(
        onTap: () {
          _productNameController.text = name;
          _ingredientsController.text = ingredients;
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ingredients,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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

      // Cache the report
      await HiveBoxes.cacheReport(report);

      // Update user scan count
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
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
