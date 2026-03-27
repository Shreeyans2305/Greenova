import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../data/models/sustainability_report_model.dart';
import '../config/api_config.dart';
import 'ai_service.dart';

/// Backend AI Service — calls the Python FastAPI backend
/// which proxies to Ollama and Open Food Facts
class BackendAiService implements AiService {
  final Dio _dio;

  BackendAiService({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? ApiConfig.backendBaseUrl,
          connectTimeout: ApiConfig.connectionTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ));

  @override
  Future<SustainabilityReport> analyzeIngredients(
    String ingredientsText, {
    String? productName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.analyzeEndpoint,
        data: {
          'text': ingredientsText,
          'product_name': productName ?? 'Product',
        },
      );
      return _parseReport(response.data, 'ingredients');
    } on DioException catch (e) {
      throw Exception('Backend connection failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to analyze ingredients: $e');
    }
  }

  @override
  Future<SustainabilityReport> searchByText(String query) async {
    try {
      final response = await _dio.post(
        ApiConfig.searchEndpoint,
        data: {'query': query},
      );
      return _parseReport(response.data, 'text', isGeneralized: true);
    } on DioException catch (e) {
      throw Exception('Backend connection failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search: $e');
    }
  }

  @override
  Future<SustainabilityReport> analyzeImage(Uint8List imageBytes) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: 'product.jpg',
        ),
      });
      final response = await _dio.post(
        ApiConfig.imageEndpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _parseReport(response.data, 'image');
    } on DioException catch (e) {
      throw Exception('Backend connection failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> generateCarbonSummary(
    List<Map<String, dynamic>> purchaseHistory,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.carbonSummaryEndpoint,
        data: {'purchase_history': purchaseHistory},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Backend connection failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to generate carbon summary: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        ApiConfig.productsSearchEndpoint,
        queryParameters: {'q': query},
      );
      final data = response.data as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? [];
      return products.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception('Product search failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> compareProducts(
    String product1,
    String product2, {
    Map<String, dynamic>? product1Data,
    Map<String, dynamic>? product2Data,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.compareEndpoint,
        data: {
          'product1': product1,
          'product2': product2,
          if (product1Data != null) 'product1_data': product1Data,
          if (product2Data != null) 'product2_data': product2Data,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Backend connection failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to compare products: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAlternatives({
    required String productName,
    required double carbonScore,
    required String sustainabilityGrade,
    String? category,
    List<String>? negativeFactors,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.alternativesEndpoint,
        data: {
          'product_name': productName,
          'carbon_score': carbonScore,
          'sustainability_grade': sustainabilityGrade,
          if (category != null) 'category': category,
          if (negativeFactors != null) 'negative_factors': negativeFactors,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Backend connection failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get alternatives: $e');
    }
  }

  SustainabilityReport _parseReport(
    dynamic data,
    String searchType, {
    bool isGeneralized = false,
  }) {
    final json = data is Map<String, dynamic>
        ? data
        : jsonDecode(data.toString()) as Map<String, dynamic>;

    // Extract eco equivalents if present
    final ecoEquivalents = json['ecoEquivalents'] as Map<String, dynamic>?;

    return SustainabilityReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: json['productName'] ?? 'Unknown Product',
      brand: json['brand'],
      carbonScore: (json['carbonScore'] as num?)?.toDouble() ?? 50.0,
      sustainabilityGrade: json['sustainabilityGrade'] ?? 'C',
      positiveFactors: List<String>.from(json['positiveFactors'] ?? []),
      negativeFactors: List<String>.from(json['negativeFactors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      detailedAnalysis: json['detailedAnalysis'] ?? '',
      searchType: searchType,
      isGeneralized: isGeneralized,
      generatedAt: DateTime.now(),
      treesNeeded: (ecoEquivalents?['treesNeeded'] as num?)?.toDouble(),
      carMiles: (ecoEquivalents?['carMiles'] as num?)?.toDouble(),
      plasticBags: (ecoEquivalents?['plasticBags'] as num?)?.toInt(),
      lightBulbHours: (ecoEquivalents?['lightBulbHours'] as num?)?.toInt(),
    );
  }
}
