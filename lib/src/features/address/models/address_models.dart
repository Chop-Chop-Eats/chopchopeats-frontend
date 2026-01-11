/// 地址Item
class AddressItem {
  ///收件地址 街道
  final String address;

  ///是否默认地址
  final bool defaultStatus;

  ///收件详细地址 (建筑/公寓/楼层/单元)
  final String? detailAddress;

  ///编号
  final int? id;

  ///手机号
  final String mobile;

  ///收件人名称
  final String name;

  ///所在城市或州
  final String state;

  ///邮政编码
  final String zipCode;

  ///纬度
  final double? latitude;

  ///经度
  final double? longitude;

  ///格式化后的地址
  final String? formattedAddress;

  AddressItem({
    required this.address,
    required this.defaultStatus,
    this.detailAddress,
    this.id,
    required this.mobile,
    required this.name,
    required this.state,
    required this.zipCode,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      address: json['address'] ?? '',
      defaultStatus: json['defaultStatus'] ?? false,
      id: json['id'],
      mobile: json['mobile'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      detailAddress: json['detailAddress'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      formattedAddress: json['formattedAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'defaultStatus': defaultStatus,
      if (detailAddress != null) 'detailAddress': detailAddress,
      if (id != null) 'id': id,
      'mobile': mobile,
      'name': name,
      'state': state,
      'zipCode': zipCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (formattedAddress != null) 'formattedAddress': formattedAddress,
    };
  }
}

enum AddressFormMode { create, edit }

class AddressFormArguments {
  AddressFormArguments({
    this.mode = AddressFormMode.create,
    this.initial,
  }) : assert(
          mode == AddressFormMode.create || initial != null,
          '编辑模式必须提供初始地址数据',
        );

  final AddressFormMode mode;
  final AddressItem? initial;

  factory AddressFormArguments.create() => AddressFormArguments(
        mode: AddressFormMode.create,
      );

  factory AddressFormArguments.edit(AddressItem initial) =>
      AddressFormArguments(
        mode: AddressFormMode.edit,
        initial: initial,
      );
}

// 州市列表
class StateItem {
  /// 州/省ID
  final int id;

  ///state 州/省名称
  final String state;

  StateItem({required this.id, required this.state});

  factory StateItem.fromJson(Map<String, dynamic> json) {
    return StateItem(id: json['id'], state: json['state']);
  }
}
