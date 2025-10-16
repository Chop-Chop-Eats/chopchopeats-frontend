import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/restaurant/restaurant_list.dart';
import '../providers/search_provider.dart';
import '../widgets/search_item.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // 监听输入框变化
    _searchController.addListener(() {
      final text = _searchController.text;
      setState(() {
        _showClearButton = text.isNotEmpty;
      });
      
      // 当输入框被清空时，清空搜索结果
      if (text.isEmpty) {
        ref.read(searchResultProvider.notifier).clearResults();
      }
    });
    
    // 延迟执行异步操作，避免在 initState 中直接调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  /// 初始化数据
  Future<void> _initializeData() async {
    // 加载关键词列表和历史记录列表
    ref.read(keywordListProvider.notifier).loadKeywords();
    ref.read(historyListProvider.notifier).loadHistories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  /// 执行搜索
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Logger.info('SearchPage', '搜索: $query');
      ref.read(searchResultProvider.notifier).search(query);
      // 搜索后重新加载历史记录列表
      ref.read(historyListProvider.notifier).loadHistories();
      // 取消输入框焦点
      FocusScope.of(context).unfocus();
    }
  }

  /// 选择历史记录项
  void _selectHistoryItem(String item) {
    _searchController.text = item;
    _performSearch();
  }

  /// 选择推荐项
  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch();
  }

  /// 清除搜索历史
  Future<void> _clearSearchHistory() async {
    try {
      await ref.read(historyListProvider.notifier).clearHistories();
      Logger.info('SearchPage', '清除搜索历史');
    } catch (e) {
      Logger.error('SearchPage', 'Failed to clear search history: $e');
    }
  }

  /// 刷新搜索结果
  Future<void> _onRefresh() async {
    await ref.read(searchResultProvider.notifier).refresh();
    _refreshController.refreshCompleted();
  }

  /// 加载更多搜索结果
  Future<void> _onLoading() async {
    await ref.read(searchResultProvider.notifier).loadMore();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final currentSearchKeyword = ref.watch(currentSearchKeywordProvider);
    final hasSearched = currentSearchKeyword != null && currentSearchKeyword.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonSpacing.medium,
              _buildSearchBar(),
              CommonSpacing.medium,
              // 根据是否有搜索结果来决定显示的内容
              Expanded(
                child: hasSearched 
                    ? _buildSearchResults()
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchHistory(),
                            CommonSpacing.medium,
                            _buildSearchSuggestion(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 返回按钮
        GestureDetector(
          onTap: () => Navigate.pop(context),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.sp,
              color: Colors.black,
            ),
          ),
        ),
        CommonSpacing.width(12.w),
        // 搜索输入框
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonSpacing.width(16.w),
                CommonImage(
                  imagePath: 'assets/images/search.png',
                  width: 16.w,
                  height: 16.h,
                ),
                CommonSpacing.width(8.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _performSearch(),
                    decoration: InputDecoration(
                      hintText: '搜索内容',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF86909C),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (_showClearButton)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      // 清空搜索结果
                      ref.read(searchResultProvider.notifier).clearResults();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Icon(
                        Icons.clear,
                        size: 18.sp,
                        color: Color(0xFF86909C),
                      ),
                    ),
                  ),
                CommonSpacing.width(8.w),
              ],
            ),
          ),
        ),
        CommonSpacing.width(12.w),
        // 搜索按钮
        GestureDetector(
          onTap: _performSearch,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '搜索',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建搜索历史
  Widget _buildSearchHistory() {
    final histories = ref.watch(historiesProvider);
    final isLoading = ref.watch(historyLoadingProvider);

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: const CommonIndicator(),
      );
    }

    if (histories.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '搜索历史',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: _clearSearchHistory,
              child: CommonImage(
                imagePath: 'assets/images/search_delete.png',
                width: 16.w,
                height: 16.h,
              ),
            ),
          ],
        ),
        CommonSpacing.medium,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: histories.map((item) {
            return GestureDetector(
              onTap: () => _selectHistoryItem(item.searchWord),
              child: SearchItem(title: item.searchWord),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建搜索推荐（猜你喜欢）
  Widget _buildSearchSuggestion() {
    final keywords = ref.watch(keywordsProvider);
    final isLoading = ref.watch(keywordLoadingProvider);

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: const CommonIndicator(),
      );
    }

    if (keywords.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '猜你喜欢',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        CommonSpacing.medium,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: keywords.map((item) {
            final isHot = item.icon != null && item.icon!.isNotEmpty;
            return GestureDetector(
              onTap: () => _selectSuggestion(item.keyWord),
              child: SearchItem(
                title: item.keyWord,
                isHot: isHot,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    final restaurants = ref.watch(searchRestaurantsProvider);
    final isLoading = ref.watch(searchLoadingProvider);
    final error = ref.watch(searchErrorProvider);
    final hasMore = ref.watch(searchHasMoreProvider);

    // 初始加载状态
    if (isLoading && restaurants.isEmpty) {
      return const CommonIndicator();
    }

    // 错误状态
    if (error != null && restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $error'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 空状态
    if (restaurants.isEmpty) {
      return Center(
        child: CommonImage(
          imagePath: 'assets/images/empty_search.png',
          width: 160.w,
          height: 120.h,
          fit: BoxFit.contain,
        ),
      );
    }

    // 展示搜索结果列表
    return RestaurantList(
      restaurants: restaurants,
      enableRefresh: true,
      refreshController: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      hasMore: hasMore,
      padding: EdgeInsets.zero,
    );
  }

}
