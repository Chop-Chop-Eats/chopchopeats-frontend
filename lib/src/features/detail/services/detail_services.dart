import '../../../core/config/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../../models/models.dart';
import '../models/detail_model.dart';

class DetailServices {
  /// 获取商户店铺 (店铺详情)
  Future<ShopModel> getShop(String id) async {
    final response = await ApiClient().get(
      ApiPaths.getShopApi, 
      queryParameters: {
        'id': id,
        'latitude': AppServices.appSettings.latitude,
        'longitude': AppServices.appSettings.longitude,
      }
    );
    Logger.info('DetailServices', '店铺详情: ${response.data}');
    return ShopModel.fromJson(response.data);
  }

  /// 获得可领取优惠券列表
  Future<AvailableCouponModel> getAvailableCouponList(String shopId) async {
    final response = await ApiClient().get(
      ApiPaths.getAvailableCouponListApi,
      queryParameters: {
        'shopId': shopId,
      }
    );
    Logger.info('DetailServices', '可领取优惠券列表: ${response.data}');
    return AvailableCouponModel.fromJson(response.data);
  }

  /// 获得可售商品列表
  Future<List<SaleProductModel>> getSaleProductList(SaleProductListQuery query) async {
    final response = await ApiClient().get(
      ApiPaths.getSaleProductListApi,
      queryParameters: query.toJson(),
    );
    Logger.info('DetailServices', '可售商品列表: ${response.data}');
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => SaleProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }
}