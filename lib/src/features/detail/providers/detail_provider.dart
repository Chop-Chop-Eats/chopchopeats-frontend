import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/detail_model.dart';
import '../services/detail_services.dart';

/// 店铺详情数据状态
class DetailState {
  final ShopModel? shop;
  final bool isLoading;
  final String? error;

  DetailState({
    this.shop,
    this.isLoading = false,
    this.error,
  });

  DetailState copyWith({
    ShopModel? shop,
    bool? isLoading,
    String? error,
  }) {
    return DetailState(
      shop: shop ?? this.shop,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 店铺详情数据状态管理
class DetailNotifier extends StateNotifier<DetailState> {
  final DetailServices _detailServices = DetailServices();

  DetailNotifier() : super(DetailState());

  /// 加载店铺详情
  Future<void> loadShopDetail(String shopId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final shop = await _detailServices.getShop(shopId);
      
      state = state.copyWith(
        shop: shop,
        isLoading: false,
      );

      Logger.info('DetailNotifier', '店铺详情加载成功: ${shop.chineseShopName}');
    } catch (e) {
      Logger.error('DetailNotifier', '店铺详情加载失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新店铺详情
  Future<void> refresh(String shopId) async {
    await loadShopDetail(shopId);
  }

  /// 更新店铺的收藏状态
  /// [shopId] 店铺ID
  /// [isFavorite] 是否收藏
  void updateShopFavorite(String shopId, bool isFavorite) {
    if (state.shop?.id == shopId) {
      state = state.copyWith(
        shop: state.shop?.copyWith(favorite: isFavorite),
      );
      Logger.info('DetailNotifier', '更新店铺收藏状态: shopId=$shopId, favorite=$isFavorite');
    }
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 店铺详情数据 Provider（使用 family 支持多个店铺）
final detailProvider = StateNotifierProvider.family<DetailNotifier, DetailState, String>((ref, shopId) {
  return DetailNotifier();
});

/// 店铺详情数据选择器
final shopDetailProvider = Provider.family<ShopModel?, String>((ref, shopId) {
  return ref.watch(detailProvider(shopId)).shop;
});

/// 店铺详情加载状态选择器
final shopDetailLoadingProvider = Provider.family<bool, String>((ref, shopId) {
  return ref.watch(detailProvider(shopId)).isLoading;
});

/// 店铺详情错误状态选择器
final shopDetailErrorProvider = Provider.family<String?, String>((ref, shopId) {
  return ref.watch(detailProvider(shopId)).error;
});

