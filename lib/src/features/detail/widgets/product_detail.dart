import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formats.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/restaurant/operating_hours.dart';
import '../../../core/widgets/restaurant/rating.dart';
import '../models/detail_model.dart';

class ProductDetail extends StatelessWidget {
  final ShopModel shop;
  final double logoHeight;
  const ProductDetail({super.key, required this.shop, required this.logoHeight});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          if(shop.newShopMark ?? false)
           _buildNewShopMark(l10n.newShopMark),
          _buildShopName(shop.localizedShopName),
          CommonSpacing.medium,
          _buildShowDesc(shop.localizedDescription ?? l10n.noShopDescription),
          CommonSpacing.medium,
          _buildRatingWithOperatingHours(
            rating: shop.rating?.toString() ?? '0.0',
            operatingHours: formatOperatingHours(shop.operatingHours),
            distance: shop.distance != null ? '${shop.distance!.toStringAsFixed(1)}km' : l10n.unknownDistance,
            commentCount: shop.commentCount?.toString() ?? '0',
            context: context,
          ),
          CommonSpacing.medium,
          // 优惠券列表
          _buildAvailableCouponList(),
        ],
      ),
    );
  }


  
  Widget _buildNewShopMark(String text) => Container(
    decoration: BoxDecoration(
      color: AppTheme.primaryOrange,
      borderRadius: BorderRadius.circular(8.r),
    ),
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonImage(imagePath: "assets/images/new.png", width: 16.w, height: 16.h),
        CommonSpacing.width(8),
        Text(text , style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),)
      ],
    ),
  );

  Widget _buildShopName(String name) => Text(name,style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),);

  Widget _buildShowDesc(String desc) => Text(desc,style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),);

  Widget _buildRatingWithOperatingHours({
    required String rating,
    required String operatingHours,
    required String distance,
    required String commentCount,
    required BuildContext context,
  }){
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
                    "($commentCount ${l10n.comments})",
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

  Widget _buildCouponItem(String title) => Container(
    decoration: BoxDecoration(
      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: AppTheme.primaryOrange, width: 1.w),
    ),
    margin: EdgeInsets.only(right: 2.w),
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    child: Text(title, style: TextStyle(color: AppTheme.primaryOrange, fontSize: 10.sp, fontWeight: FontWeight.normal),),
  );

  Widget _buildAvailableCouponList() => Row(
    children: [
      Text("领券", style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),),
      CommonSpacing.width(4),
      // 数据来源于接口 若超出一行，则显示省略号 
      Expanded(
        child: Row(
          children: [
            ...["满100减10", "满200减20", "满300减30"].map((e) => _buildCouponItem(e)),
            if (["满100减10", "满200减20", "满300减30"].length > 3)
              Text("...", style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),),
          ],
        ),
      ),
      IconButton(
        onPressed: () {}, 
        icon: Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.black,)
      ),
    ],
  );
}