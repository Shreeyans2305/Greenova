import 'dart:math';

import '../../data/models/sustainability_report_model.dart';
import 'ai_service.dart';

/// Mock AI Service for testing without real Ollama backend
/// Returns realistic dummy data for all AI operations
class MockAiService implements AiService {
  final _random = Random();

  @override
  Future<SustainabilityReport> analyzeBarcode(String barcode) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return _generateMockReport(
      productName: 'Product #$barcode',
      searchType: 'barcode',
    );
  }

  @override
  Future<SustainabilityReport> analyzeIngredients(
    String ingredientsText, {
    String? productName,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // Use provided product name or extract from ingredients
    final name = productName ?? 'Product with ingredients';

    return _generateMockReport(
      productName: name,
      searchType: 'ingredients',
      ingredientsText: ingredientsText,
    );
  }

  @override
  Future<SustainabilityReport> searchByText(String query) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    return _generateMockReport(
      productName: query,
      searchType: 'text',
      isGeneralized: true,
    );
  }

  @override
  Future<SustainabilityReport> analyzeImage(String base64Image) async {
    await Future.delayed(const Duration(seconds: 2));

    // Simulate brand detection from image
    final detectedBrands = [
      'EcoFriendly Co.',
      'GreenLife Products',
      'Nature\'s Best',
      'Sustainable Choice',
      'Earth First Brand',
    ];
    final brand = detectedBrands[_random.nextInt(detectedBrands.length)];

    return _generateMockReport(
      productName: '$brand Product',
      searchType: 'image',
      brand: brand,
    );
  }

  @override
  Future<Map<String, dynamic>> generateCarbonSummary(
    List<Map<String, dynamic>> purchaseHistory,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final totalItems = purchaseHistory.length;
    double totalCarbon = 0;

    for (final purchase in purchaseHistory) {
      totalCarbon += (purchase['carbonScore'] as num?)?.toDouble() ?? 0;
    }

    final avgCarbon = totalItems > 0 ? totalCarbon / totalItems : 0;

    String footprintLevel;
    String recommendation;

    if (avgCarbon < 30) {
      footprintLevel = 'Low';
      recommendation = 'Excellent job! Your sustainable choices are making a real difference. Keep up the great work and inspire others to follow your lead.';
    } else if (avgCarbon < 60) {
      footprintLevel = 'Medium';
      recommendation = 'You\'re on the right track! Consider swapping a few more products for eco-friendly alternatives to further reduce your footprint.';
    } else {
      footprintLevel = 'High';
      recommendation = 'There\'s room for improvement. Try choosing products with recyclable packaging and locally sourced ingredients.';
    }

    return {
      'totalPurchases': totalItems,
      'totalCarbonFootprint': totalCarbon,
      'averageCarbonScore': avgCarbon,
      'footprintLevel': footprintLevel,
      'recommendation': recommendation,
      'monthlyTrend': _generateMonthlyTrend(),
      'categoryBreakdown': _generateCategoryBreakdown(),
      'achievements': _generateAchievements(totalItems, avgCarbon),
    };
  }

  SustainabilityReport _generateMockReport({
    required String productName,
    required String searchType,
    String? ingredientsText,
    String? brand,
    bool isGeneralized = false,
  }) {
    final carbonScore = 20 + _random.nextDouble() * 60; // 20-80 range
    final grade = _calculateGrade(carbonScore);

    final positiveFactors = _getPositiveFactors(isGeneralized);
    final negativeFactors = _getNegativeFactors(isGeneralized);
    final recommendations = _getRecommendations(isGeneralized);

    return SustainabilityReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: productName,
      brand: brand,
      carbonScore: carbonScore,
      sustainabilityGrade: grade,
      positiveFactors: positiveFactors,
      negativeFactors: negativeFactors,
      recommendations: recommendations,
      detailedAnalysis: isGeneralized
          ? 'This is a generalized sustainability assessment for $productName category products.'
          : 'Detailed analysis of $productName based on $searchType scan.',
      searchType: searchType,
      isGeneralized: isGeneralized,
      generatedAt: DateTime.now(),
    );
  }

  String _calculateGrade(double score) {
    if (score < 20) return 'A';
    if (score < 40) return 'B';
    if (score < 60) return 'C';
    if (score < 80) return 'D';
    return 'F';
  }

  List<String> _getPositiveFactors(bool isGeneralized) {
    final factors = [
      'Recyclable packaging materials',
      'Low water usage in production',
      'Renewable energy used in manufacturing',
      'Biodegradable components',
      'Locally sourced ingredients',
      'Minimal plastic content',
      'Fair trade certified',
      'Organic ingredients',
      'Carbon-neutral shipping',
      'Refillable/reusable design',
    ];

    factors.shuffle(_random);
    return factors.take(isGeneralized ? 2 : 3 + _random.nextInt(2)).toList();
  }

  List<String> _getNegativeFactors(bool isGeneralized) {
    final factors = [
      'Non-recyclable plastic packaging',
      'High transportation emissions',
      'Contains palm oil',
      'Single-use design',
      'High water footprint',
      'Chemical-intensive production',
      'Non-biodegradable materials',
      'Excessive packaging',
    ];

    factors.shuffle(_random);
    return factors.take(isGeneralized ? 1 : 1 + _random.nextInt(2)).toList();
  }

  List<String> _getRecommendations(bool isGeneralized) {
    final recommendations = [
      'Consider eco-friendly alternatives with recyclable packaging',
      'Look for products with organic certifications',
      'Choose locally manufactured options when available',
      'Opt for concentrated formulas to reduce packaging waste',
      'Check for refillable options for this product category',
      'Support brands committed to carbon neutrality',
    ];

    recommendations.shuffle(_random);
    return recommendations.take(isGeneralized ? 2 : 3).toList();
  }

  List<Map<String, dynamic>> _generateMonthlyTrend() {
    return List.generate(6, (index) {
      final month = DateTime.now().subtract(Duration(days: 30 * (5 - index)));
      return {
        'month': '${month.month}/${month.year}',
        'carbonScore': 30 + _random.nextDouble() * 40,
        'itemCount': 5 + _random.nextInt(10),
      };
    });
  }

  Map<String, double> _generateCategoryBreakdown() {
    return {
      'Food & Beverages': 25 + _random.nextDouble() * 20,
      'Personal Care': 10 + _random.nextDouble() * 15,
      'Household': 15 + _random.nextDouble() * 15,
      'Electronics': 5 + _random.nextDouble() * 10,
      'Clothing': 10 + _random.nextDouble() * 15,
      'Other': 5 + _random.nextDouble() * 10,
    };
  }

  List<String> _generateAchievements(int totalItems, double avgCarbon) {
    final achievements = <String>[];

    if (totalItems >= 1) achievements.add('First Scan!');
    if (totalItems >= 10) achievements.add('Eco Explorer');
    if (totalItems >= 50) achievements.add('Sustainability Champion');
    if (totalItems >= 100) achievements.add('Green Guardian');

    if (avgCarbon < 30) achievements.add('Low Impact Hero');
    if (avgCarbon < 20) achievements.add('Eco Warrior');

    return achievements;
  }
}
