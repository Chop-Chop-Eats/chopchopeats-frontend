import 'dart:async';

import 'package:chop_user/src/core/routing/navigate.dart';
import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/restaurant/favorite_icon.dart';
import '../../../core/controllers/favorite_controller.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../models/detail_model.dart';
import '../models/order_model.dart' show formatDiningDate;
import '../providers/cart_notifier.dart';
import '../providers/detail_provider.dart';
import '../widgets/carousel_background.dart';
import '../widgets/product_detail.dart';
import '../widgets/shop_cart.dart';

class DetailPage extends ConsumerStatefulWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final double logoHeight = 200.h;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    Logger.info('DetailPage', '店铺详情页面初始化: shopId=${widget.id}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final existingShop = ref.read(shopDetailProvider(widget.id));
      if (existingShop == null) {
        Logger.info('DetailPage', '无缓存数据，开始加载: shopId=${widget.id}');
        ref.read(detailProvider(widget.id).notifier).loadShopDetail(widget.id);
      } else {
        Logger.info(
          'DetailPage',
          '使用缓存数据: shopId=${widget.id}, shopName=${existingShop.chineseShopName}',
        );
      }

      final cartNotifier = ref.read(cartProvider.notifier);
      final diningDate = formatDiningDate(DateTime.now());

      // 1. 先加载本地缓存（包括待同步操作队列）
      unawaited(
        cartNotifier.loadFromLocal(widget.id).then((_) {
          final cartState = ref.read(cartStateProvider(widget.id));
          Logger.info(
            'DetailPage',
            '本地购物车加载完成: shopId=${widget.id}, items=${cartState.items.length}, '
            'pendingOps=${cartState.pendingOperations.length}',
          );
          // 2. 如果有待同步操作，先执行批量同步
          if (cartState.hasPendingChanges) {
            Logger.info(
              'DetailPage',
              '检测到待同步操作，先执行批量同步: shopId=${widget.id}, '
              'pendingOps=${cartState.pendingOperations.length}',
            );
            unawaited(
              cartNotifier.syncPendingOperations(widget.id).then((_) {
                // 3. 批量同步完成后，再执行远程同步
                Logger.info(
                  'DetailPage',
                  '批量同步完成，执行远程同步: shopId=${widget.id}',
                );
                unawaited(
                  cartNotifier.syncFromRemote(
                    shopId: widget.id,
                    diningDate: diningDate,
                  ),
                );
              }).catchError((e) {
                Logger.error(
                  'DetailPage',
                  '批量同步失败: shopId=${widget.id}, error=$e',
                );
                // 即使批量同步失败，也尝试远程同步
                unawaited(
                  cartNotifier.syncFromRemote(
                    shopId: widget.id,
                    diningDate: diningDate,
                    skipIfPending: true, // 跳过远程同步，避免覆盖本地数据
                  ),
                );
              }),
            );
          } else {
            // 如果没有待同步操作，直接执行远程同步
            unawaited(
              cartNotifier.syncFromRemote(
                shopId: widget.id,
                diningDate: diningDate,
              ),
            );
          }
        }),
      );
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    Logger.info('DetailPage', '手动刷新店铺详情: shopId=${widget.id}');
    await ref.read(detailProvider(widget.id).notifier).refresh(widget.id);
    _refreshController.refreshCompleted();
  }

  /// 处理收藏按钮点击
  void _onFavoriteTap(ShopModel shop) async {
    // 监听收藏操作的 loading 状态，禁用时直接返回
    final hasFavoriteProcessing = ref.read(hasFavoriteProcessingProvider);
    if (hasFavoriteProcessing) {
      Logger.warn('DetailPage', '收藏操作进行中，忽略点击');
      return;
    }
    // 将 ShopModel 转换为 ChefItem
    final restaurant = shop.toChefItem();
    // 调用全局收藏控制器处理收藏操作
    try {
      await ref.read(favoriteControllerProvider).toggleFavorite(restaurant);
    } catch (e) {
      Logger.error('DetailPage', '收藏操作失败: $e');
    }
  }

  /// 构建AppBar
  Widget _buildAppBar(ShopModel? shop, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CommonAppBar(
      backgroundColor: Colors.transparent,
      titleColor: Colors.white,
      iconColor: Colors.white,
      title: l10n.merchantDetail,
      onBackPressed: () {
        Logger.info('DetailPage', '返回按钮被点击');
        Navigate.pop(context);
      },
      actions:
          shop != null
              ? [
                FavoriteIcon(
                  isFavorite: shop.favorite ?? false,
                  onTap: () => _onFavoriteTap(shop),
                ),
              ]
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shop = ref.watch(shopDetailProvider(widget.id));
    final isLoading = ref.watch(shopDetailLoadingProvider(widget.id));
    final error = ref.watch(shopDetailErrorProvider(widget.id));

    if (isLoading && shop == null) {
      return Scaffold(
        body: Stack(
          children: [
            CarouselBackground(shop: null, logoHeight: logoHeight),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(null, context),
            ),
            const Center(child: CommonIndicator()),
          ],
        ),
      );
    }

    // 错误状态
    if (error != null && shop == null) {
      return Scaffold(
        body: Stack(
          children: [
            CarouselBackground(shop: null, logoHeight: logoHeight),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(null, context),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.loadingFailedMessage(error)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(detailProvider(widget.id).notifier)
                          .loadShopDetail(widget.id);
                    },
                    child: Text(l10n.tryAgainText),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 如果没有数据，显示空状态
    if (shop == null) {
      return Scaffold(
        body: Stack(
          children: [
            CarouselBackground(shop: null, logoHeight: logoHeight),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(null, context),
            ),
            Center(child: Text(l10n.shopNotExist)),
          ],
        ),
      );
    }

    // 展示店铺详情
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          // 页面已返回，触发批量同步（后台执行，不阻塞） 12 797.68 10 708  13 975.44
          final cartState = ref.read(cartStateProvider(widget.id));
          if (cartState.hasPendingChanges) {
            Logger.info(
              'DetailPage',
              '页面返回，触发批量同步: shopId=${widget.id}, '
              'pendingOps=${cartState.pendingOperations.length}',
            );
            unawaited(
              ref.read(cartProvider.notifier).syncPendingOperations(widget.id),
            );
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 可滚动内容区域
            SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: false,
              onRefresh: _onRefresh,
              header: CustomHeader(
                // height: 120.h + MediaQuery.of(context).padding.top, // 测试ios灵动岛
                builder:
                    (context, mode) => Container(
                      color: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16.w),
                      child: CommonIndicator(size: 16.w),
                    ),
              ),
              child: Stack(
                children: [
                  CarouselBackground(shop: shop, logoHeight: logoHeight),
                  ProductDetail(shop: shop, logoHeight: logoHeight),
                ],
              ),
            ),

            // 固定在底部的购物车（不随内容滚动）
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ShopCart(shopId: widget.id),
            ),

            // 固定在顶部的AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(shop, context),
            ),
          ],
        ),
      ),
    );
  }
}
