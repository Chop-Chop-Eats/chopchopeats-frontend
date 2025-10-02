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
  final List<SelectedChefResponse> restaurants;
  final bool isLoading;
  final String? error;

  SelectedChefState({
    this.restaurants = const [],
    this.isLoading = false,
    this.error,
  });

  SelectedChefState copyWith({
    List<SelectedChefResponse>? restaurants,
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
}

/// 甄选私厨店铺数据 Provider
final selectedChefProvider = StateNotifierProvider<SelectedChefNotifier, SelectedChefState>((ref) {
  return SelectedChefNotifier();
});

/// 甄选私厨店铺数据选择器 - 只返回店铺列表
final selectedChefRestaurantsProvider = Provider<List<SelectedChefResponse>>((ref) {
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
