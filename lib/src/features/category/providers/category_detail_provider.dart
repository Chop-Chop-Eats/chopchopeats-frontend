import 'package:chop_user/src/core/config/app_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/home_models.dart';
import '../services/category_services.dart';

/// 分类详情数据状态
class CategoryDetailState {
  final List<ChefItem> restaurants;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int total;
  final bool hasMore;

  CategoryDetailState({
    this.restaurants = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.total = 0,
    this.hasMore = true,
  });

  CategoryDetailState copyWith({
    List<ChefItem>? restaurants,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? total,
    bool? hasMore,
  }) {
    return CategoryDetailState(
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

/// 分类详情数据状态管理
class CategoryDetailNotifier extends StateNotifier<CategoryDetailState> {
  final CategoryServices _categoryServices = CategoryServices();
  final _latitude = AppServices.appSettings.latitude;
  final _longitude = AppServices.appSettings.longitude;
  final _pageSize = AppServices.appSettings.pageSize;
  
  CategoryDetailNotifier() : super(CategoryDetailState());

  /// 加载分类详情数据
  Future<void> loadCategoryDetail(int categoryId) async {
    state = state.copyWith(
      isLoading: true, 
      error: null,
      currentPage: 1,
      hasMore: true,
    );
    
    try {
      final query = DiamondAreaQuery(
        categoryId: categoryId,
        latitude: _latitude,
        longitude: _longitude,
        pageNo: 1,
        pageSize: _pageSize,
      );
      
      final response = await _categoryServices.getDiamondArea(query);
      
      state = state.copyWith(
        restaurants: response.list,
        total: response.total,
        isLoading: false,
        currentPage: 1,
        hasMore: response.list.length < response.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新分类详情数据
  Future<void> refresh(int categoryId) async {
    await loadCategoryDetail(categoryId);
  }

  /// 加载更多数据
  Future<void> loadMore(int categoryId) async {
    if (!state.hasMore || state.isLoadingMore) return;
    
    state = state.copyWith(isLoadingMore: true);
    
    try {
      final nextPage = state.currentPage + 1;
      final query = DiamondAreaQuery(
        categoryId: categoryId,
        latitude: _latitude,
        longitude: _longitude,
        pageNo: nextPage,
        pageSize: _pageSize,
      );
      
      final response = await _categoryServices.getDiamondArea(query);
      
      state = state.copyWith(
        restaurants: [...state.restaurants, ...response.list],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: state.restaurants.length + response.list.length < state.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// 清除错误状态
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 分类详情数据 Provider
final categoryDetailProvider = StateNotifierProvider.family<CategoryDetailNotifier, CategoryDetailState, int>((ref, categoryId) {
  return CategoryDetailNotifier();
});

/// 分类详情餐厅列表选择器
final categoryDetailRestaurantsProvider = Provider.family<List<ChefItem>, int>((ref, categoryId) {
  return ref.watch(categoryDetailProvider(categoryId)).restaurants;
});

/// 分类详情加载状态选择器
final categoryDetailLoadingProvider = Provider.family<bool, int>((ref, categoryId) {
  return ref.watch(categoryDetailProvider(categoryId)).isLoading;
});

/// 分类详情加载更多状态选择器
final categoryDetailLoadingMoreProvider = Provider.family<bool, int>((ref, categoryId) {
  return ref.watch(categoryDetailProvider(categoryId)).isLoadingMore;
});

/// 分类详情错误状态选择器
final categoryDetailErrorProvider = Provider.family<String?, int>((ref, categoryId) {
  return ref.watch(categoryDetailProvider(categoryId)).error;
});

/// 分类详情是否有更多数据选择器
final categoryDetailHasMoreProvider = Provider.family<bool, int>((ref, categoryId) {
  return ref.watch(categoryDetailProvider(categoryId)).hasMore;
});
