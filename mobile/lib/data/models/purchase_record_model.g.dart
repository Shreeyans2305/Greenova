// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseRecordAdapter extends TypeAdapter<PurchaseRecord> {
  @override
  final int typeId = 1;

  @override
  PurchaseRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseRecord(
      id: fields[0] as String,
      productName: fields[1] as String,
      brand: fields[2] as String?,
      carbonScore: fields[3] as double,
      sustainabilityGrade: fields[4] as String,
      category: fields[5] as String,
      purchaseDate: fields[6] as DateTime,
      addedAt: fields[7] as DateTime,
      notes: fields[8] as String?,
      reportId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseRecord obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.purchaseDate)
      ..writeByte(7)
      ..write(obj.addedAt)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.reportId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
