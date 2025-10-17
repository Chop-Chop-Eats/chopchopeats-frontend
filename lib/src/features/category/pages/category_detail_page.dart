import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/restaurant/restaurant_list.dart';
import '../../../core/providers/favorite_provider.dart';
import '../providers/category_detail_provider.dart';

/// 分类详情页面 - 二级页面
class CategoryDetailPage extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;
  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryDetailProvider(widget.categoryId).notifier).loadCategoryDetail(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
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
    // final isLoadingMore = ref.watch(categoryDetailLoadingMoreProvider(widget.categoryId));
    final error = ref.watch(categoryDetailErrorProvider(widget.categoryId));
    final hasMore = ref.watch(categoryDetailHasMoreProvider(widget.categoryId));
    
    // 监听收藏操作的 loading 状态
    final hasFavoriteProcessing = ref.watch(hasFavoriteProcessingProvider);

    // 初始加载状态
    if (isLoading && restaurants.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const CommonIndicator(),
      );
    }

    // 错误状态
    if (error != null && restaurants.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('加载失败: $error'),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(categoryDetailProvider(widget.categoryId).notifier)
                              .loadCategoryDetail(widget.categoryId);
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 120.h,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigate.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.categoryName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                background: CommonImage(
                  imagePath: "assets/images/appbar_bg.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: RestaurantList(
          restaurants: restaurants,
          enableRefresh: true,
          refreshController: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          hasMore: hasMore,
          categoryId: widget.categoryId, // 传入 categoryId 用于收藏状态同步
          isInteractionDisabled: isLoading || hasFavoriteProcessing, // 页面加载或收藏操作时禁用交互
        ),
      )
    );
  }

  /// 构建顶部固定标题栏（用于错误状态）
  Widget _buildHeader() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              widget.categoryName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 48.w), // 平衡左侧按钮宽度
        ],
      ),
    );
  }
}
