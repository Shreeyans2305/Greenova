// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sustainability_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SustainabilityReportAdapter extends TypeAdapter<SustainabilityReport> {
  @override
  final int typeId = 0;

  @override
  SustainabilityReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SustainabilityReport(
      id: fields[0] as String,
      productName: fields[1] as String,
      brand: fields[2] as String?,
      carbonScore: fields[3] as double,
      sustainabilityGrade: fields[4] as String,
      positiveFactors: (fields[5] as List).cast<String>(),
      negativeFactors: (fields[6] as List).cast<String>(),
      recommendations: (fields[7] as List).cast<String>(),
      detailedAnalysis: fields[8] as String,
      searchType: fields[9] as String,
      isGeneralized: fields[10] as bool,
      generatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SustainabilityReport obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.carbonScore)
      ..writeByte(4)
      ..write(obj.sustainabilityGrade)
      ..writeByte(5)
      ..write(obj.positiveFactors)
      ..writeByte(6)
      ..write(obj.negativeFactors)
      ..writeByte(7)
      ..write(obj.recommendations)
      ..writeByte(8)
      ..write(obj.detailedAnalysis)
      ..writeByte(9)
      ..write(obj.searchType)
      ..writeByte(10)
      ..write(obj.isGeneralized)
      ..writeByte(11)
      ..write(obj.generatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SustainabilityReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
