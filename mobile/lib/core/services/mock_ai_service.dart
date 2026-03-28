import 'dart:math';
import 'dart:typed_data';

import '../../data/models/sustainability_report_model.dart';
import 'ai_service.dart';

/// Mock AI Service for testing without real backend
class MockAiService implements AiService {
  final _random = Random();

  @override
  Future<SustainabilityReport> analyzeIngredients(
    String ingredientsText, {
    String? productName,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return _generateMockReport(
      productName: productName ?? 'Product',
      searchType: 'ingredients',
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
  Future<SustainabilityReport> analyzeImage(Uint8List imageBytes) async {
    await Future.delayed(const Duration(seconds: 2));
    final brands = ['EcoFriendly Co.', 'GreenLife', 'Nature\'s Best', 'Sustainable Choice'];
    final brand = brands[_random.nextInt(brands.length)];
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
    final avgCarbon = totalItems > 0 ? totalCarbon / totalItems : 0.0;
    return {
      'totalPurchases': totalItems,
      'totalCarbonFootprint': totalCarbon,
      'averageCarbonScore': avgCarbon,
      'footprintLevel': avgCarbon < 30 ? 'Low' : avgCarbon < 60 ? 'Medium' : 'High',
      'recommendation': 'Keep making sustainable choices!',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(5, (i) => {
      'name': '$query Product ${i + 1}',
      'brand': 'Mock Brand',
      'barcode': '${1000000 + i}',
      'imageSmallUrl': '',
      'ecoscoreGrade': ['a', 'b', 'c', 'd'][_random.nextInt(4)],
      'nutriscoreGrade': ['a', 'b', 'c'][_random.nextInt(3)],
      'ingredients': 'Mock ingredients list',
    });
  }

  @override
  Future<Map<String, dynamic>> compareProducts(
    String product1,
    String product2, {
    Map<String, dynamic>? product1Data,
    Map<String, dynamic>? product2Data,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'winner': 'product1',
      'winnerName': product1,
      'summary': '$product1 has a lower environmental impact overall.',
      'product1': {
        'productName': product1,
        'carbonScore': 30 + _random.nextInt(30),
        'sustainabilityGrade': 'B',
        'positiveFactors': ['Recyclable packaging', 'Low emissions'],
        'negativeFactors': ['Contains palm oil'],
      },
      'product2': {
        'productName': product2,
        'carbonScore': 40 + _random.nextInt(40),
        'sustainabilityGrade': 'C',
        'positiveFactors': ['Organic ingredients'],
        'negativeFactors': ['High transport emissions', 'Plastic packaging'],
      },
      'comparisonFactors': [
        {'factor': 'Packaging', 'product1Score': 8, 'product2Score': 4},
        {'factor': 'Transport', 'product1Score': 7, 'product2Score': 5},
        {'factor': 'Ingredients', 'product1Score': 6, 'product2Score': 7},
      ],
    };
  }

  SustainabilityReport _generateMockReport({
    required String productName,
    required String searchType,
    String? brand,
    bool isGeneralized = false,
  }) {
    final carbonScore = 20 + _random.nextDouble() * 60;
    final grade = carbonScore < 20 ? 'A' : carbonScore < 40 ? 'B' : carbonScore < 60 ? 'C' : carbonScore < 80 ? 'D' : 'F';

    return SustainabilityReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: productName,
      brand: brand,
      carbonScore: carbonScore,
      sustainabilityGrade: grade,
      positiveFactors: ['Recyclable packaging', 'Low water usage', 'Organic ingredients'],
      negativeFactors: ['High transport emissions', 'Plastic components'],
      recommendations: ['Choose locally sourced alternatives', 'Look for refillable options'],
      detailedAnalysis: 'Mock analysis for $productName.',
      searchType: searchType,
      isGeneralized: isGeneralized,
      generatedAt: DateTime.now(),
      treesNeeded: carbonScore / 21.77,
      carMiles: carbonScore * 2.31,
      plasticBags: (carbonScore / 0.033).round(),
      lightBulbHours: (carbonScore * 1000 / 0.042).round(),
    );
  }

  @override
  Future<Map<String, dynamic>> getAlternatives({
    required String productName,
    required double carbonScore,
    required String sustainabilityGrade,
    String? category,
    List<String>? negativeFactors,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'alternatives': [
        {
          'name': 'Eco-Friendly Alternative',
          'brand': 'Green Brand',
          'estimatedCarbonScore': 20,
          'sustainabilityGrade': 'A',
          'whyBetter': 'Uses organic ingredients and recyclable packaging.',
          'keyBenefits': ['Organic', 'Recyclable'],
        },
      ],
      'generalTip': 'Look for products with eco-certifications.',
    };
  }

  @override
  Future<Map<String, dynamic>> getIpccReference() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'available': true,
      'data': {
        'source': 'Mock IPCC Data',
        'food_emission_factors': {
          'beef_herd': {'kg_co2e_per_kg': 60.0},
        }
      }
    };
  }

  @override
  Future<Map<String, dynamic>> getIpccContext(String productType) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'available': true,
      'product_type': productType,
      'emission_factors': {
        'beef_herd': {'kg_co2e_per_kg': 60.0},
      }
    };
  }
}
