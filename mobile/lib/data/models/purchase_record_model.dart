import 'package:hive/hive.dart';

import 'sustainability_report_model.dart';

part 'purchase_record_model.g.dart';

@HiveType(typeId: 1)
class PurchaseRecord extends HiveObject {
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
  final String category;

  @HiveField(6)
  final DateTime purchaseDate;

  @HiveField(7)
  final DateTime addedAt;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final String? reportId;

  PurchaseRecord({
    required this.id,
    required this.productName,
    this.brand,
    required this.carbonScore,
    required this.sustainabilityGrade,
    required this.category,
    required this.purchaseDate,
    required this.addedAt,
    this.notes,
    this.reportId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'productName': productName,
    'brand': brand,
    'carbonScore': carbonScore,
    'sustainabilityGrade': sustainabilityGrade,
    'category': category,
    'purchaseDate': purchaseDate.toIso8601String(),
    'addedAt': addedAt.toIso8601String(),
    'notes': notes,
    'reportId': reportId,
  };

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String?,
      carbonScore: (json['carbonScore'] as num).toDouble(),
      sustainabilityGrade: json['sustainabilityGrade'] as String,
      category: json['category'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      addedAt: DateTime.parse(json['addedAt'] as String),
      notes: json['notes'] as String?,
      reportId: json['reportId'] as String?,
    );
  }

  factory PurchaseRecord.fromReport(SustainabilityReport report, String category) {
    return PurchaseRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: report.productName,
      brand: report.brand,
      carbonScore: report.carbonScore,
      sustainabilityGrade: report.sustainabilityGrade,
      category: category,
      purchaseDate: DateTime.now(),
      addedAt: DateTime.now(),
      reportId: report.id,
    );
  }

  PurchaseRecord copyWith({
    String? id,
    String? productName,
    String? brand,
    double? carbonScore,
    String? sustainabilityGrade,
    String? category,
    DateTime? purchaseDate,
    DateTime? addedAt,
    String? notes,
    String? reportId,
  }) {
    return PurchaseRecord(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      carbonScore: carbonScore ?? this.carbonScore,
      sustainabilityGrade: sustainabilityGrade ?? this.sustainabilityGrade,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
      reportId: reportId ?? this.reportId,
    );
  }
}
