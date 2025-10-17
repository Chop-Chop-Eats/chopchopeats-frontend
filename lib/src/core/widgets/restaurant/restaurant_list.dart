import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../routing/navigate.dart';
import '../../routing/routes.dart';
import '../../utils/logger/logger.dart';
import '../../utils/pop/toast.dart';
import '../common_spacing.dart';
import '../common_indicator.dart';
import '../custom_refresh_footer.dart';
import 'restaurant_card.dart';
import '../../../features/home/models/home_models.dart';
import '../../controllers/favorite_controller.dart';

/// 餐厅列表组件
/// 支持可选的SmartRefresher功能（默认关闭）
class RestaurantList extends ConsumerWidget {
  final List<ChefItem> restaurants;
  
  // 刷新功能相关参数（可选）
  final bool enableRefresh;
  final RefreshController? refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final bool? hasMore;
  
  // 布局控制
  final EdgeInsetsGeometry? padding;
  final bool addBottomSpacing;
  
  // 分类ID（用于分类详情页的收藏状态同步）
  final int? categoryId;
  
  // 是否禁用收藏交互（用于加载状态）
  final bool isInteractionDisabled;

  const RestaurantList({
    super.key,
    required this.restaurants,
    this.enableRefresh = false,
    this.refreshController,
    this.onRefresh,
    this.onLoading,
    this.hasMore,
    // this.isLoadingMore, // 建议移除
    this.padding,
    this.addBottomSpacing = true,
    this.categoryId,
    this.isInteractionDisabled = false,
  });


   void _onRestaurantTap(BuildContext context, ChefItem restaurant) {
    Logger.info('RestaurantList', '点击餐厅: ${restaurant.chineseShopName} (ID: ${restaurant.id})');
    
    // 跳转到餐厅详情页面
    Navigate.push(
      context,
      Routes.detail,
      arguments: {
        'id': restaurant.id,
      },
    );
  }

  void _onFavoriteTap(WidgetRef ref, ChefItem restaurant) async {
    // 如果交互被禁用（加载中），直接返回，不做任何操作
    if (isInteractionDisabled) {
      Logger.warn('RestaurantList', '加载中，忽略收藏操作');
      return;
    }
    
    // 调用全局收藏控制器处理收藏操作
    try {
      await ref.read(favoriteControllerProvider).toggleFavorite(
        restaurant,
        categoryId: categoryId, // 传递 categoryId 用于分类详情页状态同步
      );
    } catch (e) {
      Logger.error('RestaurantList', '收藏操作失败: $e');
      // 可以在这里显示错误提示（可选）
      // if(e is ApiException) {
      //   toast.warn(e.message);
      // } else {
      //   toast.warn('收藏操作失败，请重试');
      // }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // _buildRestaurantList 现在直接返回一个 ListView
    final content = _buildRestaurantList(context, ref); 
    
    if (enableRefresh && refreshController != null) {
      return SmartRefresher(
        controller: refreshController!,
        enablePullDown: onRefresh != null,
        // 当 onLoading 为 null 时，也应该禁用上拉加载
        enablePullUp: onLoading != null && (hasMore ?? false),
        onRefresh: onRefresh,
        onLoading: onLoading,
        header: CustomHeader(
          builder: (context, mode) => Padding(
            padding: EdgeInsets.symmetric(vertical: 16.w),
            child: CommonIndicator(size: 16.w),
          ),
        ),
        footer: CustomFooter(
          builder: (context, mode) {
            // 根据加载状态显示不同的 footer
            if (mode == LoadStatus.loading) {
              return const CustomRefreshFooter();
            } else if (mode == LoadStatus.noMore) {
              return const CustomNoMoreIndicator();
            }
            // 其他状态下可以返回一个空容器
            return const SizedBox.shrink(); 
          },
        ),
        child: content,
      );
    }
    
    // 如果不启用刷新，直接返回 ListView
    return content;
  }

  Widget _buildRestaurantList(BuildContext context, WidgetRef ref) {
    // 当列表为空时，直接显示空状态视图
    if (restaurants.isEmpty) {
      // 为了让空状态居中，我们可以使用一个容器占满可用空间
      return SizedBox(
        // 让它尝试填充父组件（SmartRefresher或屏幕）的高度
        // height: MediaQuery.of(context).size.height * 0.5, 
        height: 200.h,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: const Text('暂无数据'),
          ),
        ),
      );
    }

    // 使用 ListView.builder 来构建列表，性能更好
    return ListView.builder(
      shrinkWrap: true, // 1. 根据内容确定大小
      physics: const NeverScrollableScrollPhysics(), 
      // 使用你传入的 padding，或者提供一个默认值
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
      // itemCount 需要包含所有列表项 + 可能的底部间距
      itemCount: restaurants.length + (addBottomSpacing ? 1 : 0),
      itemBuilder: (context, index) {
        // 如果是最后一项，并且需要添加底部间距
        if (addBottomSpacing && index == restaurants.length) {
          return CommonSpacing.height(20);
        }
        // 否则，构建餐厅卡片
        final restaurant = restaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          onTap: () => _onRestaurantTap(context, restaurant),
          onFavoriteTap: () => _onFavoriteTap(ref, restaurant),
        );
      },
    );
  }
}
