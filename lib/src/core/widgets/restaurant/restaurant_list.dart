import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../common_spacing.dart';
import '../common_indicator.dart';
import '../custom_refresh_footer.dart';
import 'restaurant_card.dart';
import '../../../features/home/models/home_models.dart';

/// 餐厅列表组件
/// 支持可选的SmartRefresher功能（默认关闭）
class RestaurantList extends StatelessWidget {
  final List<ChefItem> restaurants;
  final Function(ChefItem)? onRestaurantTap;
  final Function(ChefItem)? onFavoriteTap;
  
  // 刷新功能相关参数（可选）
  final bool enableRefresh;
  final RefreshController? refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final bool? hasMore;
  
  // 布局控制
  final EdgeInsetsGeometry? padding;
  final bool addBottomSpacing;

  // 注意：isLoadingMore 这个参数可以去掉，因为 SmartRefresher 的 footer 已经处理了加载更多的UI
  const RestaurantList({
    super.key,
    required this.restaurants,
    this.onRestaurantTap,
    this.onFavoriteTap,
    this.enableRefresh = false,
    this.refreshController,
    this.onRefresh,
    this.onLoading,
    this.hasMore,
    // this.isLoadingMore, // 建议移除
    this.padding,
    this.addBottomSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    // _buildRestaurantList 现在直接返回一个 ListView
    final content = _buildRestaurantList(context); 
    
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

  Widget _buildRestaurantList(BuildContext context) {
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
          onTap: () => onRestaurantTap?.call(restaurant),
          onFavoriteTap: () => onFavoriteTap?.call(restaurant),
        );
      },
    );
  }
}
