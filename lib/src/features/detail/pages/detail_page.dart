import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:chop_user/src/core/widgets/common_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/utils/formats.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/restaurant/favorite_icon.dart';
import '../../../core/widgets/restaurant/operating_hours.dart';
import '../../../core/widgets/restaurant/rating.dart';
import '../../../core/controllers/favorite_controller.dart';
import '../../../core/providers/favorite_provider.dart';
import '../models/detail_model.dart';
import '../providers/detail_provider.dart';

class DetailPage extends ConsumerStatefulWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final double logoHeight = 200.h;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  
  @override
  void initState() {
    super.initState();
    Logger.info('DetailPage', '店铺详情页面初始化: shopId=${widget.id}');
    
    //仅在无数据时请求，避免重复请求
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final existingShop = ref.read(shopDetailProvider(widget.id));
      if (existingShop == null) {
        Logger.info('DetailPage', '无缓存数据，开始加载: shopId=${widget.id}');
        ref.read(detailProvider(widget.id).notifier).loadShopDetail(widget.id);
      } else {
        Logger.info('DetailPage', '使用缓存数据: shopId=${widget.id}, shopName=${existingShop.chineseShopName}');
      }
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

  /// 构建轮播图背景
  Widget _buildCarouselBackground(ShopModel? shop) {
    // 获取背景图列表
    final backgroundImages = shop?.backgroundImage?.where((img) => img.url != null).toList() ?? [];
    
    // 如果没有背景图或为空，使用默认图片
    if (backgroundImages.isEmpty) {
      return CommonImage(
        imagePath: "assets/images/banner.png",
        height: logoHeight,
        width: 1.sw,
      );
    }

    // 如果只有一张图，直接显示
    if (backgroundImages.length == 1) {
      return CommonImage(
        imagePath: backgroundImages.first.url!,
        height: logoHeight,
        width: 1.sw,
      );
    }

    // 多张图片时使用轮播图
    return CarouselSlider(
      options: CarouselOptions(
        height: logoHeight,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        scrollDirection: Axis.horizontal,
      ),
      items: backgroundImages.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return CommonImage(
              imagePath: image.url!,
              height: logoHeight,
              width: 1.sw,
            );
          },
        );
      }).toList(),
    );
  }

  /// 构建AppBar
  Widget _buildAppBar(ShopModel? shop){
    return CommonAppBar(
      backgroundColor: Colors.transparent,
      titleColor: Colors.white,
      iconColor: Colors.white,
      title: "商家详情" , 
      actions: shop != null ? [
        FavoriteIcon(
          isFavorite: shop.favorite ?? false, 
          onTap: () => _onFavoriteTap(shop),
        ),
      ] : null,
    );
  }

  /// 构建商品详情
  Widget _buildProductDetail(ShopModel shop){
    return Container(
      margin: EdgeInsets.only(top: logoHeight-30.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShopName(shop.chineseShopName),
          CommonSpacing.medium,
          _buildShowDesc(shop.chineseDescription ?? '暂无店铺描述'),
          CommonSpacing.medium,
          _buildRatingWithOperatingHours(
            rating: shop.rating?.toString() ?? '0.0',
            operatingHours: formatOperatingHours(shop.operatingHours),
            distance: shop.distance != null ? '${shop.distance!.toStringAsFixed(1)}km' : '距离未知',
            commentCount: shop.commentCount?.toString() ?? '0',
          ),
        ],
      ),
    );
  }

  Widget _buildShopName(String name) => Text(name,style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),);

  Widget _buildShowDesc(String desc) => Text(desc,style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),);

  Widget _buildRatingWithOperatingHours({
    required String rating,
    required String operatingHours,
    required String distance,
    required String commentCount,
  }){
    LinearGradient gradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 250, 250, 253),
        Color.fromARGB(255, 197, 197, 194).withValues(alpha: 0.04),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: gradient,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w , vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Rating(rating: rating),
                  CommonSpacing.width(8),
                  Text(
                    "($commentCount 条评论)",
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold , color: Colors.grey[500]),
                  ),
                ],
              ),
              CommonSpacing.medium,
              OperatingHours(operatingHours: operatingHours),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CommonImage(imagePath: "assets/images/location.png", width: 20.w, height: 20.h),
              Text(
                distance,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold , color: Colors.grey[500]),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(shopDetailProvider(widget.id));
    final isLoading = ref.watch(shopDetailLoadingProvider(widget.id));
    final error = ref.watch(shopDetailErrorProvider(widget.id));

    if (isLoading && shop == null) {
      return Scaffold(
        body: Stack(
          children: [
            _buildCarouselBackground(null),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(null),
            ),
            const Center(
              child: CommonIndicator(),
            ),
          ],
        ),
      );
    }

    // 错误状态
    if (error != null && shop == null) {
      return Scaffold(
        body: Stack(
          children: [
            _buildCarouselBackground(null),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(null),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('加载失败: $error'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(detailProvider(widget.id).notifier).loadShopDetail(widget.id);
                    },
                    child: const Text('重试'),
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
            _buildCarouselBackground(null),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(null),
            ),
            const Center(
              child: Text('店铺信息不存在'),
            ),
          ],
        ),
      );
    }

    // 展示店铺详情
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false, // 详情页不需要上拉加载
        onRefresh: _onRefresh,
        header: CustomHeader(
          builder: (context, mode) => Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 16.w),
            child: CommonIndicator(size: 16.w), // 使用 CommonIndicator
          ),
        ),
        child: Stack(
          children: [
            _buildCarouselBackground(shop),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(shop),
            ),
            _buildProductDetail(shop),
          ],
        ),
      ),
    );
  }
}