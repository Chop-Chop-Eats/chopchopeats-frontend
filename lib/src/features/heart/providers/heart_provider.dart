import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_services.dart';
import '../../../core/utils/logger/logger.dart';
import '../../home/models/home_models.dart';
import '../../models/models.dart';
import '../services/heart_services.dart';

/// 收藏列表数据状态
class HeartState {
  final List<ChefItem> restaurants;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int total;
  final bool hasMore;

  HeartState({
    this.restaurants = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.total = 0,
    this.hasMore = true,
  });

  HeartState copyWith({
    List<ChefItem>? restaurants,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? total,
    bool? hasMore,
  }) {
    return HeartState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// 收藏列表数据状态管理
class HeartNotifier extends StateNotifier<HeartState> {
  final HeartServices _heartServices = HeartServices();
  final _latitude = AppServices.appSettings.latitude;
  final _longitude = AppServices.appSettings.longitude;
  final _pageSize = AppServices.appSettings.pageSize;

  HeartNotifier() : super(HeartState());

  /// 加载收藏列表数据
  Future<void> loadFavorites() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: 1,
      hasMore: true,
    );

    try {
      final query = CommonQuery(
        pageNo: 1,
        pageSize: _pageSize,
        latitude: _latitude,
        longitude: _longitude,
      );

      final response = await _heartServices.getFavorite(query);

      // 将 FavoriteItem 转换为 ChefItem
      final restaurants = response.list.map((item) => item.toChefItem()).toList();

      state = state.copyWith(
        restaurants: restaurants,
        total: response.total,
        isLoading: false,
        currentPage: 1,
        hasMore: restaurants.length < response.total,
      );

      Logger.info('HeartNotifier', '收藏列表加载成功，共 ${response.total} 条');
    } catch (e) {
      Logger.error('HeartNotifier', '收藏列表加载失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新收藏列表数据
  Future<void> refresh() async {
    await loadFavorites();
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final query = CommonQuery(
        pageNo: nextPage,
        pageSize: _pageSize,
        latitude: _latitude,
        longitude: _longitude,
      );

      final response = await _heartServices.getFavorite(query);

      // 将 FavoriteItem 转换为 ChefItem
      final newRestaurants = response.list.map((item) => item.toChefItem()).toList();

      state = state.copyWith(
        restaurants: [...state.restaurants, ...newRestaurants],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: state.restaurants.length + newRestaurants.length < state.total,
      );

      Logger.info('HeartNotifier', '加载更多成功，当前页: $nextPage');
    } catch (e) {
      Logger.error('HeartNotifier', '加载更多失败: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// 更新单个餐厅的收藏状态
  /// [shopId] 店铺ID
  /// [isFavorite] 是否收藏
  void updateRestaurantFavorite(String shopId, bool isFavorite) {
    if (!isFavorite) {
      // 如果是取消收藏，从列表中移除
      final updatedList = state.restaurants.where((restaurant) => restaurant.id != shopId).toList();
      state = state.copyWith(
        restaurants: updatedList,
        total: state.total - 1,
      );
      Logger.info('HeartNotifier', '从收藏列表移除: $shopId');
    } else {
      // 如果是添加收藏，需要重新加载列表以获取完整数据
      Logger.info('HeartNotifier', '添加收藏，建议刷新列表');
    }
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 收藏列表数据 Provider
final heartProvider = StateNotifierProvider<HeartNotifier, HeartState>((ref) {
  return HeartNotifier();
});

/// 收藏列表餐厅数据选择器
final heartRestaurantsProvider = Provider<List<ChefItem>>((ref) {
  return ref.watch(heartProvider).restaurants;
});

/// 收藏列表加载状态选择器
final heartLoadingProvider = Provider<bool>((ref) {
  return ref.watch(heartProvider).isLoading;
});

/// 收藏列表加载更多状态选择器
final heartLoadingMoreProvider = Provider<bool>((ref) {
  return ref.watch(heartProvider).isLoadingMore;
});

/// 收藏列表错误状态选择器
final heartErrorProvider = Provider<String?>((ref) {
  return ref.watch(heartProvider).error;
});

/// 收藏列表是否有更多数据选择器
final heartHasMoreProvider = Provider<bool>((ref) {
  return ref.watch(heartProvider).hasMore;
});

