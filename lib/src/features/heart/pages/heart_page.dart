import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/base_page.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/restaurant/restaurant_list.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/providers/tab_index_provider.dart';
import '../../home/models/home_models.dart';
import '../providers/heart_provider.dart';

class HeartPage extends ConsumerStatefulWidget {
  const HeartPage({super.key});

  @override
  ConsumerState<HeartPage> createState() => _HeartPageState();
}

class _HeartPageState extends ConsumerState<HeartPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    Logger.info('HeartPage', '我的收藏页面初始化');
    
    // 加载初始数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(heartProvider.notifier).loadFavorites();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(heartProvider.notifier).refresh();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await ref.read(heartProvider.notifier).loadMore();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(heartRestaurantsProvider);
    final isLoading = ref.watch(heartLoadingProvider);
    final error = ref.watch(heartErrorProvider);
    final hasMore = ref.watch(heartHasMoreProvider);
    
    // 监听收藏操作的 loading 状态
    final hasFavoriteProcessing = ref.watch(hasFavoriteProcessingProvider);

    // 【方案一】监听 Tab 切换：当切换到收藏页时自动刷新
    ref.listen<int>(currentTabIndexProvider, (previous, next) {
      // 当从其他页面切换到收藏页（index=1）时，自动刷新数据
      if (next == 1 && previous != 1 && mounted) {
        Logger.info('HeartPage', '检测到切换到收藏页，自动刷新数据');
        ref.read(heartProvider.notifier).refresh();
      }
    });

    return BasePage(
      title: "收藏",
      content: _buildContent(
        restaurants: restaurants,
        isLoading: isLoading,
        error: error,
        hasMore: hasMore,
        hasFavoriteProcessing: hasFavoriteProcessing,
      ),
    );
  }

  Widget _buildContent({
    required List<ChefItem> restaurants,
    required bool isLoading,
    required String? error,
    required bool hasMore,
    required bool hasFavoriteProcessing,
  }) {
    // 初始加载状态
    if (isLoading && restaurants.isEmpty) {
      return const Center(
        child: CommonIndicator(),
      );
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
              onPressed: () {
                ref.read(heartProvider.notifier).loadFavorites();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 空状态
    if (restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImage(imagePath: "assets/images/empty_heart.png", width: 160.w, height: 120.h),
            CommonSpacing.large,
            Text('暂未收藏任何餐厅', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            TextButton(
              onPressed: () {
                Navigate.push(context, Routes.home);
              },
              child: Text('去逛逛', style: TextStyle(fontSize: 14.sp, color: AppTheme.primaryOrange)),
            ),
          ],
        ),
      );
    }

    // 展示收藏列表
    return RestaurantList(
      padding: EdgeInsets.zero,
      restaurants: restaurants,
      enableRefresh: true,
      refreshController: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      hasMore: hasMore,
      isInteractionDisabled: isLoading || hasFavoriteProcessing, // 页面加载或收藏操作时禁用交互
    );
  }
}