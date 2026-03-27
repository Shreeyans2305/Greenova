import '../../data/models/sustainability_report_model.dart';

/// Abstract AI Service interface
/// Allows switching between mock and real Ollama implementations
abstract class AiService {
  /// Analyze a product by its barcode and return a sustainability report
  Future<SustainabilityReport> analyzeBarcode(String barcode);

  /// Analyze product ingredients text and return a sustainability report
  Future<SustainabilityReport> analyzeIngredients(
    String ingredientsText, {
    String? productName,
  });

  /// Search for product sustainability info by text query
  Future<SustainabilityReport> searchByText(String query);

  /// Analyze a product image and return a detailed sustainability report
  Future<SustainabilityReport> analyzeImage(String base64Image);

  /// Generate a carbon footprint summary for purchase history
  Future<Map<String, dynamic>> generateCarbonSummary(
    List<Map<String, dynamic>> purchaseHistory,
  );
}
