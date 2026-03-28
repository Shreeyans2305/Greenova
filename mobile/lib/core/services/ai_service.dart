import 'dart:typed_data';

import '../../data/models/sustainability_report_model.dart';

/// Abstract AI Service interface
/// Supports text analysis, image analysis, product search, and comparison
abstract class AiService {
  /// Analyze product ingredients text and return a sustainability report
  Future<SustainabilityReport> analyzeIngredients(
    String ingredientsText, {
    String? productName,
  });

  /// Search for product sustainability info by text query
  Future<SustainabilityReport> searchByText(String query);

  /// Analyze a product image and return a detailed sustainability report
  Future<SustainabilityReport> analyzeImage(Uint8List imageBytes);

  /// Generate a carbon footprint summary for purchase history
  Future<Map<String, dynamic>> generateCarbonSummary(
    List<Map<String, dynamic>> purchaseHistory,
  );

  /// Search products from Open Food Facts
  Future<List<Map<String, dynamic>>> searchProducts(String query);

  /// Compare two products
  Future<Map<String, dynamic>> compareProducts(
    String product1,
    String product2, {
    Map<String, dynamic>? product1Data,
    Map<String, dynamic>? product2Data,
  });

  /// Get eco-friendly alternatives for a high-carbon product
  Future<Map<String, dynamic>> getAlternatives({
    required String productName,
    required double carbonScore,
    required String sustainabilityGrade,
    String? category,
    List<String>? negativeFactors,
  });

  /// Get full IPCC AR6 reference data
  Future<Map<String, dynamic>> getIpccReference();

  /// Get IPCC AR6 data filtered by product type
  Future<Map<String, dynamic>> getIpccContext(String productType);
}
