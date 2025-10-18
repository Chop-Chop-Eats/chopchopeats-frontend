import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:chop_user/src/core/widgets/common_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/restaurant/favorite_icon.dart';
import '../../../core/widgets/restaurant/operating_hours.dart';
import '../../../core/widgets/restaurant/rating.dart';
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
  
  @override
  void initState() {
    super.initState();
    Logger.info('DetailPage', '店铺详情页面初始化: shopId=${widget.id}');
    
    // 加载店铺详情数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(detailProvider(widget.id).notifier).loadShopDetail(widget.id);
    });
  }

  /// 构建AppBar
  Widget _buildAppBar(ShopModel? shop){
    return CommonAppBar(
      backgroundColor: Colors.transparent,
      titleColor: Colors.white,
      iconColor: Colors.white,
      title: "商家详情" , 
      actions: [
        FavoriteIcon(
          isFavorite: shop?.favorite ?? false, 
          onTap: () {
            //
          }
        ),
      ],
    );
  }


  /// 构建商品详情
  Widget _buildProductDetail(ShopModel shop){
    // 格式化营业时间
    String operatingHoursText = '营业时间未知';
    if (shop.operatingHours != null && shop.operatingHours!.isNotEmpty) {
      final firstHour = shop.operatingHours!.first;
      if (firstHour.time != null && firstHour.remark != null) {
        operatingHoursText = '${firstHour.time} ${firstHour.remark}';
      } else if (firstHour.time != null) {
        operatingHoursText = firstHour.time!;
      } else if (firstHour.remark != null) {
        operatingHoursText = firstHour.remark!;
      }
    }

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
            operatingHours: operatingHoursText,
            distance: shop.distance != null ? '${shop.distance!.toStringAsFixed(1)}km' : '距离未知',
            commentCount: shop.commentCount?.toString() ?? '0',
          ),
        ],
      ),
    );
  }

  Widget _buildShopName(String name){
    return Text(
      name,
      style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildShowDesc(String desc){
    return Text(
      desc,
      style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
    );
  }

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

    // 加载状态
    if (isLoading && shop == null) {
      return Scaffold(
        body: Stack(
          children: [
            CommonImage(imagePath: "assets/images/banner.png", height: logoHeight),
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
            CommonImage(imagePath: "assets/images/banner.png", height: logoHeight),
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
            CommonImage(imagePath: "assets/images/banner.png", height: logoHeight),
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
      body: Stack(
        children: [
          // 背景图：优先使用店铺背景图，否则使用默认图片
          CommonImage(
            imagePath: shop.backgroundImage?.isNotEmpty == true 
              ? shop.backgroundImage!.first.url ?? "assets/images/banner.png"
              : "assets/images/banner.png",
            height: logoHeight,
            width: 200.w, /// 100% 宽度
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildAppBar(shop),
          ),
          _buildProductDetail(shop),
        ],
      ),
    );
  }
}