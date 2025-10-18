import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/heart/services/heart_services.dart';
import '../../features/heart/providers/heart_provider.dart';
import '../../features/home/models/home_models.dart';
import '../../features/home/providers/home_provider.dart';
import '../../features/category/providers/category_detail_provider.dart';
import '../../features/search/providers/search_provider.dart';
import '../providers/favorite_provider.dart';
import '../utils/logger/logger.dart';

/// 全局收藏控制器
/// 负责统一处理收藏/取消收藏操作，并同步更新所有页面的状态
class FavoriteController {
  final Ref ref;
  final HeartServices _heartServices = HeartServices();

  FavoriteController(this.ref);

  /// 切换收藏状态（添加或取消收藏）
  /// 使用乐观更新策略：先更新UI，失败则回滚
  /// [restaurant] 餐厅信息
  /// [categoryId] 可选的分类ID，如果在分类详情页调用则传入
  Future<void> toggleFavorite(ChefItem restaurant, {int? categoryId}) async {
    final isFavorite = restaurant.favorite ?? false;
    final shopId = restaurant.id; // 店铺ID
    final favoriteId = restaurant.favoriteId; // 收藏ID 

    // 标记为正在处理中
    ref.read(favoriteStateProvider.notifier).startProcessing(shopId);

    // 乐观更新：先更新所有页面的UI
    _syncFavoriteState(shopId, !isFavorite, categoryId: categoryId);

    try {
      if (isFavorite) {
        // 取消收藏
        // 注意：这里使用 shopId 作为 favoriteId，因为当前接口可能缺少 favoriteId
        // 如果后端返回了 favoriteId，应该使用 restaurant.favoriteId
        if (favoriteId == null) {
          throw Exception('收藏ID为空');
        }
        await _heartServices.cancelFavorite(
          shopId: shopId,
          favoriteId: favoriteId,
        );
        toast.success('取消收藏成功');
      } else {
        // 添加收藏
        await _heartServices.addFavorite(shopId: shopId);
        toast.success('添加收藏成功');
      }
    } catch (e) {
      // 操作失败，回滚UI状态
      Logger.error('FavoriteController', '收藏操作失败: $e');
      _syncFavoriteState(shopId, isFavorite, categoryId: categoryId);
      
      // 重新抛出异常，让UI层可以选择性地显示错误提示
      rethrow;
    } finally {
      // 无论成功还是失败，都标记为处理完成
      ref.read(favoriteStateProvider.notifier).endProcessing(shopId);
      Logger.info('FavoriteController', '收藏操作处理完成: $shopId');
    }
  }

  /// 同步收藏状态到所有页面
  /// [shopId] 店铺ID
  /// [isFavorite] 是否收藏
  /// [categoryId] 可选的分类ID
  void _syncFavoriteState(String shopId, bool isFavorite, {int? categoryId}) {
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

    // 更新分类详情页（如果提供了 categoryId）
    if (categoryId != null) {
      try {
        ref.read(categoryDetailProvider(categoryId).notifier)
          .updateRestaurantFavorite(shopId, isFavorite);
        Logger.info('FavoriteController', '更新分类详情页状态成功 (categoryId: $categoryId)');
      } catch (e) {
        Logger.warn('FavoriteController', '更新分类详情页状态失败: $e');
      }
    }

    // 更新收藏页的列表
    try {
      ref.read(heartProvider.notifier)
        .updateRestaurantFavorite(shopId, isFavorite);
      Logger.info('FavoriteController', '更新收藏页状态成功');
    } catch (e) {
      Logger.warn('FavoriteController', '更新收藏页状态失败: $e');
    }
  }
}

/// 全局收藏控制器 Provider
final favoriteControllerProvider = Provider<FavoriteController>((ref) {
  return FavoriteController(ref);
});

