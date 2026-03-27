import 'package:hive/hive.dart';

part 'sustainability_report_model.g.dart';

@HiveType(typeId: 0)
class SustainabilityReport extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String? brand;

  @HiveField(3)
  final double carbonScore;

  @HiveField(4)
  final String sustainabilityGrade;

  @HiveField(5)
  final List<String> positiveFactors;

  @HiveField(6)
  final List<String> negativeFactors;

  @HiveField(7)
  final List<String> recommendations;

  @HiveField(8)
  final String detailedAnalysis;

  @HiveField(9)
  final String searchType;

  @HiveField(10)
  final bool isGeneralized;

  @HiveField(11)
  final DateTime generatedAt;

  SustainabilityReport({
    required this.id,
    required this.productName,
    this.brand,
    required this.carbonScore,
    required this.sustainabilityGrade,
    required this.positiveFactors,
    required this.negativeFactors,
    required this.recommendations,
    required this.detailedAnalysis,
    required this.searchType,
    required this.isGeneralized,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'productName': productName,
    'brand': brand,
    'carbonScore': carbonScore,
    'sustainabilityGrade': sustainabilityGrade,
    'positiveFactors': positiveFactors,
    'negativeFactors': negativeFactors,
    'recommendations': recommendations,
    'detailedAnalysis': detailedAnalysis,
    'searchType': searchType,
    'isGeneralized': isGeneralized,
    'generatedAt': generatedAt.toIso8601String(),
  };

  factory SustainabilityReport.fromJson(Map<String, dynamic> json) {
    return SustainabilityReport(
      id: json['id'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String?,
      carbonScore: (json['carbonScore'] as num).toDouble(),
      sustainabilityGrade: json['sustainabilityGrade'] as String,
      positiveFactors: List<String>.from(json['positiveFactors'] ?? []),
      negativeFactors: List<String>.from(json['negativeFactors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      detailedAnalysis: json['detailedAnalysis'] as String? ?? '',
      searchType: json['searchType'] as String,
      isGeneralized: json['isGeneralized'] as bool? ?? false,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  SustainabilityReport copyWith({
    String? id,
    String? productName,
    String? brand,
    double? carbonScore,
    String? sustainabilityGrade,
    List<String>? positiveFactors,
    List<String>? negativeFactors,
    List<String>? recommendations,
    String? detailedAnalysis,
    String? searchType,
    bool? isGeneralized,
    DateTime? generatedAt,
  }) {
    return SustainabilityReport(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      carbonScore: carbonScore ?? this.carbonScore,
      sustainabilityGrade: sustainabilityGrade ?? this.sustainabilityGrade,
      positiveFactors: positiveFactors ?? this.positiveFactors,
      negativeFactors: negativeFactors ?? this.negativeFactors,
      recommendations: recommendations ?? this.recommendations,
      detailedAnalysis: detailedAnalysis ?? this.detailedAnalysis,
      searchType: searchType ?? this.searchType,
      isGeneralized: isGeneralized ?? this.isGeneralized,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
