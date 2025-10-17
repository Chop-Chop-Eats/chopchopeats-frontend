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
  
  /// 获取我的收藏
  Future<FavoriteModel> getFavorite(CommonQuery query) async {
    final response = await ApiClient().get(
      ApiPaths.getFavoriteApi,
      queryParameters: query.toJson(),
    );
    Logger.info('DetailServices', '我的收藏: ${response.data}');
    return FavoriteModel.fromJson(response.data);
  }

  /// 添加收藏 入参: shopId 店铺Id
  Future<void> addFavorite({required String shopId}) async {
    final response = await ApiClient().post(
      ApiPaths.addFavoriteApi,
      queryParameters: {
        'shopId': shopId, // 店铺Id
      },
    );
  }

  /// 取消收藏 入参: shopId 店铺Id, favoriteId 收藏Id
  Future<void> cancelFavorite({required String shopId, required String favoriteId}) async {
    final response = await ApiClient().post(
      ApiPaths.cancelFavoriteApi,
      data: {
        'shopId': shopId, // 店铺Id
        'favoriteId': favoriteId, // 收藏Id
      },
    );
  }
}