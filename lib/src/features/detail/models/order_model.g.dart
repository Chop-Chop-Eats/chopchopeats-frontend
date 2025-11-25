// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemModelAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 2;

  @override
  CartItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItemModel(
      createTime: fields[0] as DateTime?,
      diningDate: fields[1] as String?,
      id: fields[2] as String?,
      imageThumbnail: fields[3] as String?,
      price: fields[4] as double?,
      productId: fields[5] as String?,
      productName: fields[6] as String?,
      productSpecId: fields[7] as String?,
      productSpecName: fields[8] as String?,
      quantity: fields[9] as int?,
      shopId: fields[10] as String?,
      skuSetting: fields[11] as int?,
      userId: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.createTime)
      ..writeByte(1)
      ..write(obj.diningDate)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.imageThumbnail)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.productId)
      ..writeByte(6)
      ..write(obj.productName)
      ..writeByte(7)
      ..write(obj.productSpecId)
      ..writeByte(8)
      ..write(obj.productSpecName)
      ..writeByte(9)
      ..write(obj.quantity)
      ..writeByte(10)
      ..write(obj.shopId)
      ..writeByte(11)
      ..write(obj.skuSetting)
      ..writeByte(12)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
