import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_services.dart';
import '../../../core/utils/logger/logger.dart';
import '../../home/models/home_models.dart';
import '../models/search_models.dart';
import '../services/search_services.dart';

/// 关键词列表状态
class KeywordListState {
  final List<KeywordItem> keywords;
  final bool isLoading;
  final String? error;

  KeywordListState({
    this.keywords = const [],
    this.isLoading = false,
    this.error,
  });

  KeywordListState copyWith({
    List<KeywordItem>? keywords,
    bool? isLoading,
    String? error,
  }) {
    return KeywordListState(
      keywords: keywords ?? this.keywords,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 关键词列表 Notifier
class KeywordListNotifier extends StateNotifier<KeywordListState> {
  KeywordListNotifier() : super(KeywordListState());

  /// 加载关键词列表
  Future<void> loadKeywords() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final keywords = await SearchServices.getKeywordList();
      state = state.copyWith(
        keywords: keywords,
        isLoading: false,
      );
      Logger.info('KeywordListNotifier', '关键词列表加载成功，共 ${keywords.length} 条');
    } catch (e) {
      Logger.error('KeywordListNotifier', '关键词列表加载失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// 历史记录列表状态
class HistoryListState {
  final List<HistoryItem> histories;
  final bool isLoading;
  final String? error;

  HistoryListState({
    this.histories = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryListState copyWith({
    List<HistoryItem>? histories,
    bool? isLoading,
    String? error,
  }) {
    return HistoryListState(
      histories: histories ?? this.histories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 历史记录列表 Notifier
class HistoryListNotifier extends StateNotifier<HistoryListState> {
  HistoryListNotifier() : super(HistoryListState());

  /// 加载历史记录列表
  Future<void> loadHistories() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final histories = await SearchServices.getHistoryList();
      state = state.copyWith(
        histories: histories,
        isLoading: false,
      );
      Logger.info('HistoryListNotifier', '历史记录列表加载成功，共 ${histories.length} 条');
    } catch (e) {
      Logger.error('HistoryListNotifier', '历史记录列表加载失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 清除历史记录
  Future<void> clearHistories() async {
    try {
      state = state.copyWith(histories: []);
      Logger.info('HistoryListNotifier', '历史记录已清除');
    } catch (e) {
      Logger.error('HistoryListNotifier', '清除历史记录失败: $e');
      state = state.copyWith(error: e.toString());
    }
  }
}

/// 搜索结果状态
class SearchResultState {
  final List<ChefItem> restaurants;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int total;
  final bool hasMore;
  final String? currentSearchKeyword;

  SearchResultState({
    this.restaurants = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.total = 0,
    this.hasMore = true,
    this.currentSearchKeyword,
  });

  SearchResultState copyWith({
    List<ChefItem>? restaurants,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? total,
    bool? hasMore,
    String? currentSearchKeyword,
  }) {
    return SearchResultState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      currentSearchKeyword: currentSearchKeyword ?? this.currentSearchKeyword,
    );
  }
}

/// 搜索结果 Notifier
class SearchResultNotifier extends StateNotifier<SearchResultState> {
  final _latitude = AppServices.appSettings.latitude;
  final _longitude = AppServices.appSettings.longitude;
  final _pageSize = AppServices.appSettings.pageSize;

  SearchResultNotifier() : super(SearchResultState());

  /// 执行搜索
  Future<void> search(String keyword) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: 1,
      hasMore: true,
      currentSearchKeyword: keyword,
    );

    try {
      
      final query = SearchQuery(
        search: keyword,
        pageNo: 1,
        pageSize: _pageSize,
        latitude: _latitude,
        longitude: _longitude,
      );

      final response = await SearchServices.searchShop(query);
      
      state = state.copyWith(
        restaurants: response.list,
        total: response.total,
        isLoading: false,
        currentPage: 1,
        hasMore: response.list.length < response.total,
      );
      
      Logger.info('SearchResultNotifier', '搜索成功: $keyword，共 ${response.total} 条结果');
    } catch (e) {
      Logger.error('SearchResultNotifier', '搜索失败: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新搜索结果
  Future<void> refresh() async {
    if (state.currentSearchKeyword != null) {
      await search(state.currentSearchKeyword!);
    }
  }

  /// 加载更多搜索结果
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.currentSearchKeyword == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final query = SearchQuery(
        search: state.currentSearchKeyword!,
        pageNo: nextPage,
        pageSize: _pageSize,
        latitude: _latitude,
        longitude: _longitude,
      );

      final response = await SearchServices.searchShop(query);

      state = state.copyWith(
        restaurants: [...state.restaurants, ...response.list],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: state.restaurants.length + response.list.length < state.total,
      );
      
      Logger.info('SearchResultNotifier', '加载更多成功，当前页: $nextPage');
    } catch (e) {
      Logger.error('SearchResultNotifier', '加载更多失败: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// 清空搜索结果
  void clearResults() {
    state = SearchResultState();
  }
}

// ============= Providers =============

/// 关键词列表 Provider
final keywordListProvider = StateNotifierProvider<KeywordListNotifier, KeywordListState>((ref) {
  return KeywordListNotifier();
});

/// 关键词列表数据选择器
final keywordsProvider = Provider<List<KeywordItem>>((ref) {
  return ref.watch(keywordListProvider).keywords;
});

/// 关键词列表加载状态选择器
final keywordLoadingProvider = Provider<bool>((ref) {
  return ref.watch(keywordListProvider).isLoading;
});

/// 历史记录列表 Provider
final historyListProvider = StateNotifierProvider<HistoryListNotifier, HistoryListState>((ref) {
  return HistoryListNotifier();
});

/// 历史记录列表数据选择器
final historiesProvider = Provider<List<HistoryItem>>((ref) {
  return ref.watch(historyListProvider).histories;
});

/// 历史记录列表加载状态选择器
final historyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(historyListProvider).isLoading;
});

/// 搜索结果 Provider
final searchResultProvider = StateNotifierProvider<SearchResultNotifier, SearchResultState>((ref) {
  return SearchResultNotifier();
});

/// 搜索结果餐厅列表选择器
final searchRestaurantsProvider = Provider<List<ChefItem>>((ref) {
  return ref.watch(searchResultProvider).restaurants;
});

/// 搜索结果加载状态选择器
final searchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(searchResultProvider).isLoading;
});

/// 搜索结果加载更多状态选择器
final searchLoadingMoreProvider = Provider<bool>((ref) {
  return ref.watch(searchResultProvider).isLoadingMore;
});

/// 搜索结果错误状态选择器
final searchErrorProvider = Provider<String?>((ref) {
  return ref.watch(searchResultProvider).error;
});

/// 搜索结果是否有更多数据选择器
final searchHasMoreProvider = Provider<bool>((ref) {
  return ref.watch(searchResultProvider).hasMore;
});

/// 当前搜索关键词选择器
final currentSearchKeywordProvider = Provider<String?>((ref) {
  return ref.watch(searchResultProvider).currentSearchKeyword;
});

