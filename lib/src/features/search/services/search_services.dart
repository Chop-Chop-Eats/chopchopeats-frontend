import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../../home/models/home_models.dart';
import '../models/search_models.dart';

class SearchServices {
  /// 获取关键词列表
  static Future<List<KeywordItem>> getKeywordList() async {
    final response = await ApiClient().get(ApiPaths.getKeywordListApi);
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => KeywordItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    } 
  }

  /// 获取历史记录列表
  static Future<List<HistoryItem>> getHistoryList() async {
    final response = await ApiClient().get(ApiPaths.getHistoryListApi);
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => HistoryItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }

  /// 搜索私厨店铺
  static Future<TotalWithChefItem> searchShop(SearchQuery query) async {
    final response = await ApiClient().get(
      ApiPaths.searchShopApi, 
      queryParameters: query.toJson(),
    );
    Logger.info('SearchServices', '搜索私厨店铺: ${response.data}');
    return TotalWithChefItem.fromJson(response.data);
  }

  /// 清除搜索记录
  static Future<void> clearSearchHistory() async {
    try {
      await ApiClient().delete(ApiPaths.clearSearchHistoryApi);
      Logger.info('SearchServices', '清除搜索记录成功');
    } catch (e) {
      Logger.error('SearchServices', '清除搜索记录失败: $e');
    }
  }
}