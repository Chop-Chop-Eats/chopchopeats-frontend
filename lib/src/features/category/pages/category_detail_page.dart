import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/custom_sliver_app_bar.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/restaurant_card.dart';
import '../../../core/widgets/custom_refresh_header.dart';
import '../../../core/widgets/custom_refresh_footer.dart';
import '../../home/models/home_models.dart';
import '../providers/category_detail_provider.dart';

/// 分类详情页面 - 二级页面
class CategoryDetailPage extends ConsumerStatefulWidget {
  final int categoryId;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);


  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryDetailProvider(widget.categoryId).notifier).loadCategoryDetail(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final shouldShowTitle = _scrollController.offset > 50.h;
      if (shouldShowTitle != _showTitle) {
        setState(() {
          _showTitle = shouldShowTitle;
        });
      }
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(categoryDetailProvider(widget.categoryId).notifier).refresh(widget.categoryId);
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await ref.read(categoryDetailProvider(widget.categoryId).notifier).loadMore(widget.categoryId);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(categoryDetailRestaurantsProvider(widget.categoryId));
    final isLoading = ref.watch(categoryDetailLoadingProvider(widget.categoryId));
    final isLoadingMore = ref.watch(categoryDetailLoadingMoreProvider(widget.categoryId));
    final error = ref.watch(categoryDetailErrorProvider(widget.categoryId));
    final hasMore = ref.watch(categoryDetailHasMoreProvider(widget.categoryId));

    if (isLoading && restaurants.isEmpty) {
      return Scaffold(
        appBar: CommonAppBar(
          title: '加载中...',
        ),
        body: const CommonIndicator(),
      );
    }

    if (error != null && restaurants.isEmpty) {
      return Scaffold(
        appBar: CommonAppBar(
          title: '分类详情',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: $error'),
              CommonSpacing.height(16),
              ElevatedButton(
                onPressed: () {
                  ref.read(categoryDetailProvider(widget.categoryId).notifier).loadCategoryDetail(widget.categoryId);
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: hasMore,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        header: CustomHeader(
          builder: (context, mode) => CustomRefreshHeader(),
        ),
        footer: CustomFooter(
          builder: (context, mode) => hasMore ? const CustomRefreshFooter() : const CustomNoMoreIndicator(),
        ),
        child: _buildRefreshContent(restaurants, isLoadingMore)
      ),
    );
  }


  Widget _buildRefreshContent(List<SelectedChefResponse> restaurants, bool isLoadingMore){
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverAppBar(),
        if (restaurants.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Text('暂无数据'),
            ),
          ),
        // 餐厅列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final restaurant = restaurants[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: RestaurantCard(
                  restaurant: restaurant,
                  onTap: () => _onRestaurantTap(restaurant),
                  onFavoriteTap: () => _onFavoriteTap(restaurant),
                ),
              );
            },
            childCount: restaurants.length,
          ),
        ),
        // 加载更多指示器
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: const CommonIndicator(),
            ),
          ),
        // 底部间距
        SliverToBoxAdapter(
          child: CommonSpacing.height(20),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return CustomSliverAppBar(
      backgroundColor: Colors.white,
      expandedHeight: 64.h,
      backgroundWidget: CommonImage(
        imagePath: "assets/images/appbar_bg.png",
      ),
      titleWidget: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 50),
        child: Text(
          '分类详情',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      showBackButton: true,
      backButtonColor: Colors.black,
    );
  }

  void _onRestaurantTap(SelectedChefResponse restaurant) {
    Logger.info('CategoryDetailPage', '点击餐厅: ${restaurant.chineseShopName}');
  }

  void _onFavoriteTap(SelectedChefResponse restaurant) {
    Logger.info('CategoryDetailPage', '收藏餐厅: ${restaurant.chineseShopName}');
  }
}
