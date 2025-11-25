// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartTotalsAdapter extends TypeAdapter<CartTotals> {
  @override
  final int typeId = 4;

  @override
  CartTotals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartTotals(
      subtotal: fields[0] as double,
      serviceFee: fields[1] as double,
      taxAmount: fields[2] as double,
      deliveryFee: fields[3] as double,
      couponOffset: fields[4] as double,
      tipAmount: fields[5] as double,
      payable: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CartTotals obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.subtotal)
      ..writeByte(1)
      ..write(obj.serviceFee)
      ..writeByte(2)
      ..write(obj.taxAmount)
      ..writeByte(3)
      ..write(obj.deliveryFee)
      ..writeByte(4)
      ..write(obj.couponOffset)
      ..writeByte(5)
      ..write(obj.tipAmount)
      ..writeByte(6)
      ..write(obj.payable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartTotalsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CartStateAdapter extends TypeAdapter<CartState> {
  @override
  final int typeId = 5;

  @override
  CartState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartState(
      shopId: fields[0] as String,
      diningDate: fields[1] as String,
      items: (fields[2] as List).cast<CartItemModel>(),
      totals: fields[3] as CartTotals,
      lastSyncedAt: fields[4] as DateTime?,
      dataOrigin: fields[5] as CartDataOrigin,
      isSyncing: fields[6] as bool,
      isUpdating: fields[7] as bool,
      isOperating: fields[8] as bool,
      error: fields[9] as String?,
      lastError: fields[10] as String?,
      pendingOperations: (fields[13] as List).cast<PendingCartOperation>(),
      lastSyncAttemptAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CartState obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.shopId)
      ..writeByte(1)
      ..write(obj.diningDate)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.totals)
      ..writeByte(4)
      ..write(obj.lastSyncedAt)
      ..writeByte(5)
      ..write(obj.dataOrigin)
      ..writeByte(6)
      ..write(obj.isSyncing)
      ..writeByte(7)
      ..write(obj.isUpdating)
      ..writeByte(8)
      ..write(obj.isOperating)
      ..writeByte(9)
      ..write(obj.error)
      ..writeByte(10)
      ..write(obj.lastError)
      ..writeByte(11)
      ..write(obj.operatingProductId)
      ..writeByte(12)
      ..write(obj.operatingProductSpecId)
      ..writeByte(13)
      ..write(obj.pendingOperations)
      ..writeByte(14)
      ..write(obj.lastSyncAttemptAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CartDataOriginAdapter extends TypeAdapter<CartDataOrigin> {
  @override
  final int typeId = 3;

  @override
  CartDataOrigin read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CartDataOrigin.local;
      case 1:
        return CartDataOrigin.remote;
      default:
        return CartDataOrigin.local;
    }
  }

  @override
  void write(BinaryWriter writer, CartDataOrigin obj) {
    switch (obj) {
      case CartDataOrigin.local:
        writer.writeByte(0);
        break;
      case CartDataOrigin.remote:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartDataOriginAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
