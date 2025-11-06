import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../models/address_models.dart';

class AddressServices {
  /// 获取州市列表
  static Future<List<StateItem>> getStateList() async {
    final response = await ApiClient().get(ApiPaths.getStateListApi);
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((e) => StateItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }

  /// 获取用户配送地址列表
  static Future<List<AddressItem>> getUserAddressList() async {
    final response = await ApiClient().get(ApiPaths.getUserAddressListApi);
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList
          .map((e) => AddressItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }

  /// 获取用户配送地址
  static Future<AddressItem> getUserAddress(int id) async {
    final response = await ApiClient().get(
      ApiPaths.getUserAddressApi,
      queryParameters: {'id': id},
    );
    return AddressItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// 获取默认用户配送地址
  static Future<AddressItem> getDefaultUserAddress() async {
    final response = await ApiClient().get(ApiPaths.getDefaultUserAddressApi);
    return AddressItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// 创建用户配送地址
  static Future<AddressItem> createUserAddress(AddressItem params) async {
    final response = await ApiClient().post(
      ApiPaths.createUserAddressApi,
      data: params.toJson(),
    );
    return AddressItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// 更新用户配送地址
  static Future<AddressItem> updateUserAddress(AddressItem params) async {
    final response = await ApiClient().put(
      ApiPaths.updateUserAddressApi,
      data: params.toJson(),
    );
    return AddressItem.fromJson(response.data as Map<String, dynamic>);
  }

  /// 删除用户配送地址
  static Future<void> deleteUserAddress(int id) async {
    final response = await ApiClient().delete(
      ApiPaths.deleteUserAddressApi,
      queryParameters: {'id': id},
    );
    return response.data;
  }
}
