import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common_spacing.dart';
import '../common_image.dart';
import '../../../features/home/models/home_models.dart';

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

  /// 格式化营业时间
  String _formatOperatingHours(List<OperatingHour>? operatingHours) {
    if (operatingHours == null || operatingHours.isEmpty) {
      return '营业时间未知';
    }
    
    // 取第一个营业时间作为显示
    final firstHour = operatingHours.first;
    if (firstHour.time != null && firstHour.remark != null) {
      return '${firstHour.time} ${firstHour.remark}';
    } else if (firstHour.time != null) {
      return firstHour.time!;
    } else if (firstHour.remark != null) {
      return firstHour.remark!;
    }
    
    return '营业时间未知';
  }

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
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        CommonImage(imagePath: "assets/images/star.png", height: 16.h),
                        CommonSpacing.width(4),
                        Text(
                          restaurant.rating?.toString() ?? '0.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        CommonSpacing.width(8),
                        CommonImage(imagePath: "assets/images/clock.png", height: 16.h),
                        CommonSpacing.width(4),
                        Expanded(
                          child: Text(
                            _formatOperatingHours(restaurant.operatingHours),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
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
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: CommonImage(imagePath: restaurant.favorite ?? false ? "assets/images/heart_s.png" : "assets/images/heart.png", width: 20.w, height: 20.h),
                        ),
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
