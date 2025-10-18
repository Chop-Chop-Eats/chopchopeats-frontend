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
}