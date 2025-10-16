import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_models.dart';
import '../services/home_services.dart';

/// 分类数据状态
class CategoryState {
  final List<CategoryListItem> categories;
  final bool isLoading;
  final String? error;

  CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<CategoryListItem>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// banner数据状态
class BannerState {
  final List<BannerItem> banners;
  final bool isLoading;
  final String? error;

  BannerState({this.banners = const [], this.isLoading = false, this.error});

  BannerState copyWith({
    List<BannerItem>? banners,
    bool? isLoading,
    String? error,
  }) {
    return BannerState(banners: banners ?? this.banners, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
  }
}

/// 分类数据状态管理
class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(CategoryState());

  /// 加载分类列表
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await HomeServices.getCategoryList();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新分类数据
  Future<void> refresh() async {
    await loadCategories();
  }
}

/// 分类数据 Provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier();
});

/// 分类数据选择器 - 只返回分类列表
final categoriesProvider = Provider<List<CategoryListItem>>((ref) {
  return ref.watch(categoryProvider).categories;
});

/// 分类加载状态选择器
final categoryLoadingProvider = Provider<bool>((ref) {
  return ref.watch(categoryProvider).isLoading;
});

/// 分类错误状态选择器
final categoryErrorProvider = Provider<String?>((ref) {
  return ref.watch(categoryProvider).error;
});

/// 甄选私厨店铺数据状态
class SelectedChefState {
  final List<ChefItem> restaurants;
  final bool isLoading;
  final String? error;

  SelectedChefState({
    this.restaurants = const [],
    this.isLoading = false,
    this.error,
  });

  SelectedChefState copyWith({
    List<ChefItem>? restaurants,
    bool? isLoading,
    String? error,
  }) {
    return SelectedChefState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 甄选私厨店铺数据状态管理
class SelectedChefNotifier extends StateNotifier<SelectedChefState> {
  SelectedChefNotifier() : super(SelectedChefState());

  /// 加载甄选私厨店铺列表
  Future<void> loadSelectedChef({
    int? categoryId,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final query = SelectedChefQuery(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
      );
      final restaurants = await HomeServices.getSelectedChef(query);
      state = state.copyWith(
        restaurants: restaurants,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }


  /// 刷新甄选私厨店铺数据
  Future<void> refresh({
    int? categoryId,
    required double latitude,
    required double longitude,
  }) async {
    await loadSelectedChef(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// 更新单个餐厅的收藏状态
  /// [shopId] 店铺ID
  /// [isFavorite] 是否收藏
  void updateRestaurantFavorite(String shopId, bool isFavorite) {
    final updatedList = state.restaurants.map((restaurant) {
      if (restaurant.id == shopId) {
        return restaurant.copyWith(favorite: isFavorite);
      }
      return restaurant;
    }).toList();
    
    state = state.copyWith(restaurants: updatedList);
  }
}

/// banner数据状态管理
class BannerNotifier extends StateNotifier<BannerState> {
  BannerNotifier() : super(BannerState());

  /// 加载banner列表
  Future<void> loadBannerList() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final banners = await HomeServices.getBannerList();
      state = state.copyWith(
        banners: banners,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

/// 甄选私厨店铺数据 Provider
final selectedChefProvider = StateNotifierProvider<SelectedChefNotifier, SelectedChefState>((ref) {
  return SelectedChefNotifier();
});

/// 甄选私厨店铺数据选择器 - 只返回店铺列表
final selectedChefRestaurantsProvider = Provider<List<ChefItem>>((ref) {
  return ref.watch(selectedChefProvider).restaurants;
});

/// 甄选私厨店铺加载状态选择器
final selectedChefLoadingProvider = Provider<bool>((ref) {
  return ref.watch(selectedChefProvider).isLoading;
});

/// 甄选私厨店铺错误状态选择器
final selectedChefErrorProvider = Provider<String?>((ref) {
  return ref.watch(selectedChefProvider).error;
});


/// banner数据 Provider
final bannerProvider = StateNotifierProvider<BannerNotifier, BannerState>((ref) {
  return BannerNotifier();
});

/// banner数据选择器 - 只返回banner列表
final bannersProvider = Provider<List<BannerItem>>((ref) {
  return ref.watch(bannerProvider).banners;
});

/// banner加载状态选择器
final bannerLoadingProvider = Provider<bool>((ref) {
  return ref.watch(bannerProvider).isLoading;
});

/// banner错误状态选择器
final bannerErrorProvider = Provider<String?>((ref) {
  return ref.watch(bannerProvider).error;
});