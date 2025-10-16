import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/detail/services/detail_services.dart';
import '../../features/home/models/home_models.dart';
import '../../features/home/providers/home_provider.dart';
import '../../features/search/providers/search_provider.dart';
import '../utils/logger/logger.dart';

/// 全局收藏控制器
/// 负责统一处理收藏/取消收藏操作，并同步更新所有页面的状态
class FavoriteController {
  final Ref ref;
  final DetailServices _detailServices = DetailServices();

  FavoriteController(this.ref);

  /// 切换收藏状态（添加或取消收藏）
  /// 使用乐观更新策略：先更新UI，失败则回滚
  Future<void> toggleFavorite(ChefItem restaurant) async {
    final isFavorite = restaurant.favorite ?? false;
    final shopId = restaurant.id; // 店铺ID 等待接口修复
    // final favoriteId = restaurant.favoriteId; // 收藏ID 等待接口修复

    Logger.info('FavoriteController', 
      '${isFavorite ? "取消收藏" : "添加收藏"}：店铺 ${restaurant.chineseShopName} (ID: $shopId)');

    // 乐观更新：先更新所有页面的UI
    _syncFavoriteState(shopId, !isFavorite);

    try {
      if (isFavorite) {
        // 取消收藏
        // 注意：这里使用 shopId 作为 favoriteId，因为当前接口可能缺少 favoriteId
        // 如果后端返回了 favoriteId，应该使用 restaurant.favoriteId
        await _detailServices.cancelFavorite(
          shopId: shopId,
          favoriteId: shopId, // 临时方案，等待接口修复
        );
        Logger.info('FavoriteController', '取消收藏成功');
      } else {
        // 添加收藏
        await _detailServices.addFavorite(shopId: shopId);
        Logger.info('FavoriteController', '添加收藏成功');
      }
    } catch (e) {
      // 操作失败，回滚UI状态
      Logger.error('FavoriteController', '收藏操作失败: $e');
      _syncFavoriteState(shopId, isFavorite);
      
      // 重新抛出异常，让UI层可以选择性地显示错误提示
      rethrow;
    }
  }

  /// 同步收藏状态到所有页面
  /// [shopId] 店铺ID
  /// [isFavorite] 是否收藏
  void _syncFavoriteState(String shopId, bool isFavorite) {
    Logger.info('FavoriteController', '同步收藏状态: shopId=$shopId, isFavorite=$isFavorite');

    // 更新首页的甄选私厨列表
    try {
      ref.read(selectedChefProvider.notifier)
        .updateRestaurantFavorite(shopId, isFavorite);
    } catch (e) {
      Logger.warn('FavoriteController', '更新首页状态失败: $e');
    }

    // 更新搜索页的结果列表
    try {
      ref.read(searchResultProvider.notifier)
        .updateRestaurantFavorite(shopId, isFavorite);
    } catch (e) {
      Logger.warn('FavoriteController', '更新搜索页状态失败: $e');
    }

    // 更新分类详情页（需要特殊处理）
    // 由于分类详情页是按 categoryId 分开管理的，这里无法直接遍历所有实例
    // 解决方案：在分类详情页中监听收藏变化事件，或者在进入页面时刷新数据
    // 目前采用简单方案：分类详情页在每次从后台恢复时刷新数据
    Logger.info('FavoriteController', '分类详情页状态需在页面恢复时刷新');
  }
}

/// 全局收藏控制器 Provider
final favoriteControllerProvider = Provider<FavoriteController>((ref) {
  return FavoriteController(ref);
});

