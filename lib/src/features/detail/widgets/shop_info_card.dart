import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/restaurant/operating_hours.dart';
import '../../../core/widgets/restaurant/rating.dart';
import '../../home/models/home_models.dart';
import '../models/detail_model.dart';
import 'coupon_list.dart';

/// 店铺信息卡片组件
class ShopInfoCard extends StatelessWidget {
  final ShopModel shop;
  final double logoHeight;

  const ShopInfoCard({
    super.key,
    required this.shop,
    required this.logoHeight,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: EdgeInsets.only(top: logoHeight - 30.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 新店标识
          if (shop.newShopMark ?? false)
            _buildNewShopMark(l10n.newShopMark),
          
          // 店铺名称
          _buildShopName(shop.localizedShopName),
          CommonSpacing.medium,
          
          // 店铺描述
          _buildShowDesc(shop.localizedDescription ?? l10n.noShopDescription),
          CommonSpacing.medium,
          
          // 评分和营业时间
          _buildRatingWithOperatingHours(
            rating: shop.rating?.toString() ?? '0.0',
            operatingHours: shop.operatingHours ?? [],
            distance: shop.distance != null ? '${shop.distance!.toStringAsFixed(1)}km' : l10n.unknownDistance,
            commentCount: shop.commentCount?.toString() ?? '0',
            context: context,
          ),
          CommonSpacing.medium,
          
          // 优惠券列表
          CouponList(shopId: shop.id),
        ],
      ),
    );
  }

  /// 新店标识
  Widget _buildNewShopMark(String text) => Container(
    decoration: BoxDecoration(
      color: AppTheme.primaryOrange,
      borderRadius: BorderRadius.circular(8.r),
    ),
    margin: EdgeInsets.only(bottom: 4.h),
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonImage(imagePath: "assets/images/new.png", width: 16.w, height: 16.h),
        CommonSpacing.width(8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    ),
  );

  /// 店铺名称
  Widget _buildShopName(String name) => Text(
    name,
    style: TextStyle(
      color: Colors.black,
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
    ),
  );

  /// 店铺描述
  Widget _buildShowDesc(String desc) => Text(
    desc,
    style: TextStyle(
      color: Colors.black,
      fontSize: 14.sp,
      fontWeight: FontWeight.normal,
    ),
  );

  /// 评分和营业时间
  Widget _buildRatingWithOperatingHours({
    required String rating,
    required List<OperatingHour> operatingHours,
    required String distance,
    required String commentCount,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                    "($commentCount ${l10n.comments})",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              CommonSpacing.medium,
              Wrap(
                children: operatingHours.map((e) => OperatingHours(operatingHours: e.time ?? '')).toList(),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CommonImage(imagePath: "assets/images/location.png", width: 20.w, height: 20.h),
              Text(
                distance,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
