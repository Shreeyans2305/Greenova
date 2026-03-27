import 'dart:convert';

import 'package:dio/dio.dart';

import '../../data/models/sustainability_report_model.dart';
import '../config/api_config.dart';
import 'ai_service.dart';

/// Real Ollama AI Service implementation
/// Connects to Ollama API running Gemma 3:12b model
class OllamaAiService implements AiService {
  final Dio _dio;

  OllamaAiService({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? ApiConfig.ollamaBaseUrl,
          connectTimeout: ApiConfig.connectionTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
          },
        ));

  @override
  Future<SustainabilityReport> analyzeBarcode(String barcode) async {
    final prompt = '''
Analyze this product barcode and provide a sustainability report.
Barcode: $barcode

Respond in JSON format with the following structure:
{
  "productName": "Product name or description",
  "carbonScore": 0-100 (lower is better),
  "sustainabilityGrade": "A/B/C/D/F",
  "positiveFactors": ["list of positive environmental factors"],
  "negativeFactors": ["list of negative environmental factors"],
  "recommendations": ["sustainability recommendations"],
  "detailedAnalysis": "Detailed sustainability analysis text"
}
''';

    return _generateReport(prompt, 'barcode');
  }

  @override
  Future<SustainabilityReport> analyzeIngredients(
    String ingredientsText, {
    String? productName,
  }) async {
    final productLabel = productName ?? 'Product';
    final prompt = '''
Analyze these product ingredients for sustainability and environmental impact.
Product Name: $productLabel
Ingredients: $ingredientsText

Respond in JSON format with the following structure:
{
  "productName": "$productLabel",
  "carbonScore": 0-100 (lower is better),
  "sustainabilityGrade": "A/B/C/D/F",
  "positiveFactors": ["list of positive environmental factors"],
  "negativeFactors": ["list of negative environmental factors"],
  "recommendations": ["sustainability recommendations"],
  "detailedAnalysis": "Detailed sustainability analysis text"
}
''';

    return _generateReport(prompt, 'ingredients');
  }

  @override
  Future<SustainabilityReport> searchByText(String query) async {
    final prompt = '''
Provide a generalized sustainability report for the product category: $query

This should be a general overview of environmental considerations for this type of product, not a specific product.

Respond in JSON format with the following structure:
{
  "productName": "$query",
  "carbonScore": 0-100 (average for this category),
  "sustainabilityGrade": "A/B/C/D/F",
  "positiveFactors": ["general positive environmental factors for this category"],
  "negativeFactors": ["general negative environmental factors for this category"],
  "recommendations": ["recommendations for choosing sustainable options"],
  "detailedAnalysis": "General sustainability overview for this product category"
}
''';

    return _generateReport(prompt, 'text', isGeneralized: true);
  }

  @override
  Future<SustainabilityReport> analyzeImage(String base64Image) async {
    final prompt = '''
Analyze this product image and provide a detailed sustainability report.
Identify the brand and product if visible.

[Image data is provided separately]

Respond in JSON format with the following structure:
{
  "productName": "Product name",
  "brand": "Brand name if identifiable",
  "carbonScore": 0-100 (lower is better),
  "sustainabilityGrade": "A/B/C/D/F",
  "positiveFactors": ["list of positive environmental factors"],
  "negativeFactors": ["list of negative environmental factors"],
  "recommendations": ["sustainability recommendations"],
  "detailedAnalysis": "Detailed sustainability analysis text"
}
''';

    // Note: Gemma model may have limited image capabilities
    // For production, consider multimodal models
    return _generateReport(prompt, 'image', imageBase64: base64Image);
  }

  @override
  Future<Map<String, dynamic>> generateCarbonSummary(
    List<Map<String, dynamic>> purchaseHistory,
  ) async {
    final historyJson = jsonEncode(purchaseHistory);

    final prompt = '''
Analyze this purchase history and generate a carbon footprint summary.
Purchase History: $historyJson

Respond in JSON format with:
{
  "totalPurchases": number,
  "totalCarbonFootprint": number,
  "averageCarbonScore": number,
  "footprintLevel": "Low/Medium/High",
  "recommendation": "Personalized recommendation text",
  "monthlyTrend": [{"month": "MM/YYYY", "carbonScore": number, "itemCount": number}],
  "categoryBreakdown": {"category": percentage},
  "achievements": ["earned achievement badges"]
}
''';

    try {
      final response = await _dio.post(
        ApiConfig.generateEndpoint,
        data: {
          'model': ApiConfig.ollamaModel,
          'prompt': prompt,
          'stream': false,
          'format': 'json',
        },
      );

      final responseText = response.data['response'] as String;
      return jsonDecode(responseText) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to generate carbon summary: $e');
    }
  }

  Future<SustainabilityReport> _generateReport(
    String prompt,
    String searchType, {
    bool isGeneralized = false,
    String? imageBase64,
  }) async {
    try {
      final requestData = {
        'model': ApiConfig.ollamaModel,
        'prompt': prompt,
        'stream': false,
        'format': 'json',
      };

      // Add image if provided (for multimodal support)
      if (imageBase64 != null) {
        requestData['images'] = [imageBase64];
      }

      final response = await _dio.post(
        ApiConfig.generateEndpoint,
        data: requestData,
      );

      final responseText = response.data['response'] as String;
      final jsonResponse = jsonDecode(responseText) as Map<String, dynamic>;

      return SustainabilityReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: jsonResponse['productName'] ?? 'Unknown Product',
        brand: jsonResponse['brand'],
        carbonScore: (jsonResponse['carbonScore'] as num?)?.toDouble() ?? 50.0,
        sustainabilityGrade: jsonResponse['sustainabilityGrade'] ?? 'C',
        positiveFactors: List<String>.from(jsonResponse['positiveFactors'] ?? []),
        negativeFactors: List<String>.from(jsonResponse['negativeFactors'] ?? []),
        recommendations: List<String>.from(jsonResponse['recommendations'] ?? []),
        detailedAnalysis: jsonResponse['detailedAnalysis'] ?? '',
        searchType: searchType,
        isGeneralized: isGeneralized,
        generatedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw Exception('Failed to connect to Ollama: ${e.message}');
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
