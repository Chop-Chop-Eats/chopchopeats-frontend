// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_cart_operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingCartOperationAdapter extends TypeAdapter<PendingCartOperation> {
  @override
  final int typeId = 1;

  @override
  PendingCartOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingCartOperation(
      type: fields[0] as CartOperationType,
      operationId: fields[1] as String,
      paramsJson: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      retryCount: fields[4] as int,
      productId: fields[5] as String?,
      productSpecId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingCartOperation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.operationId)
      ..writeByte(2)
      ..write(obj.paramsJson)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retryCount)
      ..writeByte(5)
      ..write(obj.productId)
      ..writeByte(6)
      ..write(obj.productSpecId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingCartOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CartOperationTypeAdapter extends TypeAdapter<CartOperationType> {
  @override
  final int typeId = 0;

  @override
  CartOperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CartOperationType.add;
      case 1:
        return CartOperationType.update;
      case 2:
        return CartOperationType.remove;
      default:
        return CartOperationType.add;
    }
  }

  @override
  void write(BinaryWriter writer, CartOperationType obj) {
    switch (obj) {
      case CartOperationType.add:
        writer.writeByte(0);
        break;
      case CartOperationType.update:
        writer.writeByte(1);
        break;
      case CartOperationType.remove:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartOperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
