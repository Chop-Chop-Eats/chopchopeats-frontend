import '../../../core/enums/auth_enums.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/home_models.dart';

class HomeServices {
  /// 获取甄选私厨店铺
  static Future<List<ChefItem>> getSelectedChef(SelectedChefQuery query) async {
    final response = await ApiClient().get(
      ApiPaths.getSelectedChefApi,
      queryParameters: query.toJson(),
    );
    Logger.info("HomeServices", "获取甄选私厨店铺: ${response.data}");
    if( response.data is List ){
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => ChefItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }
  
  // 获取分类浏览私厨店铺
  static Future<DiamondAreaResponse> getDiamondArea(DiamondAreaQuery query) async {
    final response = await ApiClient().get(
      ApiPaths.getDiamondAreaApi,
      queryParameters: query.toJson(),
    );
    Logger.info("HomeServices", "获取分类浏览私厨店铺: ${response.data}");
    return DiamondAreaResponse.fromJson(response.data);
  }
  
  // 获取店铺分类列表
  static Future<List<CategoryListItem>> getCategoryList() async {
    final response = await ApiClient().get(ApiPaths.getCategoryListApi);
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => CategoryListItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }

  // 获取banner列表
  static Future<List<BannerItem>> getBannerList() async {
    final response = await ApiClient().get(
      ApiPaths.getBannerListApi,
      queryParameters: {
        'pageId': BannerPageIdEnum.home.index+1,
      },
    );
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => BannerItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }
}