import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/home_models.dart';

class HomeServices {
  /// 获取甄选私厨店铺
  static Future<SelectedChefResponse> getSelectedChef() async {
    final response = await ApiClient().get(ApiPaths.getSelectedChefApi);
    Logger.info("HomeServices", "获取甄选私厨店铺: ${response.data}");
    return SelectedChefResponse.fromJson(response.data);
  }
  
  // 获取分类浏览私厨店铺
  static Future<DiamondAreaResponse> getDiamondArea() async {
    final response = await ApiClient().get(ApiPaths.getDiamondAreaApi);
    Logger.info("HomeServices", "获取分类浏览私厨店铺: ${response.data}");
    return DiamondAreaResponse.fromJson(response.data);
  }
  
  // 获取店铺分类列表
  static Future<CategoryListItem> getCategoryList() async {
    final response = await ApiClient().get(ApiPaths.getCategoryListApi);
    Logger.info("HomeServices", "获取店铺分类列表: ${response.data}");
    return CategoryListItem.fromJson(response.data);
  }
}