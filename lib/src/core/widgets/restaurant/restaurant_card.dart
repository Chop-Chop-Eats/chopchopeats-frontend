import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/formats.dart';
import '../common_spacing.dart';
import '../common_image.dart';
import '../../../features/home/models/home_models.dart';
import 'favorite_icon.dart';
import 'operating_hours.dart';
import 'rating.dart';

/// 餐厅卡片组件
class RestaurantCard extends StatelessWidget {
  final ChefItem restaurant;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CommonRoundedImage(
              imagePath: restaurant.shopLogo ?? 'assets/images/restaurant1.png',
              width: 100.w,
              height: 100.h,
              borderRadius: 16.r,
              placeholder: Container(
                width: 100.w,
                height: 100.h,
                color: Colors.grey[200],
                child: Icon(
                  Icons.restaurant,
                  color: Colors.grey[400],
                  size: 30.w,
                ),
              ),
              errorWidget: Container(
                width: 100.w,
                height: 100.h,
                color: Colors.grey[100],
                child: Icon(
                  Icons.restaurant,
                  color: Colors.grey[400],
                  size: 30.w,
                ),
              ),
            ),
            CommonSpacing.width(12),
            Expanded(
              child: SizedBox(
                height: 100.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      restaurant.chineseShopName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      restaurant.categoryChineseName ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        Rating(rating: restaurant.rating?.toString() ?? '0.0'),
                        CommonSpacing.width(8),
                        OperatingHours(operatingHours: formatOperatingHours(restaurant.operatingHours)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          restaurant.distance != null ? '${restaurant.distance!.toStringAsFixed(1)}km' : '距离未知',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        FavoriteIcon(isFavorite: restaurant.favorite ?? false, onTap: onFavoriteTap ?? () {}),
                      ],
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
}
